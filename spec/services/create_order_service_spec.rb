require "rails_helper"

RSpec.describe CreateOrderService, type: :service do
  it "prevents oversell under concurrent orders", :no_transaction do
    category = create(:category, name: "Gadgets")
    product  = create(:product, name: "Widget", price: 10.0, stock_quantity: 5, category: category)
    user1    = create(:user, email: "u1@example.com")
    user2    = create(:user, email: "u2@example.com")

    items = [ { product_id: product.id, quantity: 3 } ]
    results = Concurrent::Array.new

    threads = [ user1, user2 ].map do |u|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            order = CreateOrderService.new(user: u, items: items).call
            results << { success: true, id: order.id }
          rescue => e
            results << { success: false, error: e.message }
          end
        end
      end
    end

    threads.each(&:join)

    product.reload
    sold = OrderItem.sum(:quantity)

    expect(sold).to be <= 5
    expect(product.stock_quantity).to be >= 0
    expect(results.count { |r| r[:success] }).to be <= 1
    expect(results.count { |r| !r[:success] }).to be >= 1
    expect(results.any? { |r| r[:error].include?("Not enough stock") }).to be true
  end
end
