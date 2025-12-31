require "rails_helper"

RSpec.describe "Cart checkout", type: :request do
  let(:user)     { create(:user) }
  let(:category) { create(:category, name: "Test Category") }
  let!(:product) { create(:product, name: "P", price: 10.0, stock_quantity: 5, category: category) }

  before { sign_in user }

  it "creates order, reduces stock, and clears cart" do
    post add_item_cart_path, params: { product_id: product.id, quantity: 2 }
    expect(response).to have_http_status(:ok)

    post checkout_cart_path
    expect(response).to have_http_status(:created)
    expect(response.media_type).to eq("application/json")

    json = JSON.parse(response.body)
    expect(json["order_id"]).to be_present
    expect(json["total_price"].to_f).to eq(20.0)

    order = Order.find(json["order_id"])
    expect(order.user).to eq(user)
    expect(order.order_items.first.product).to eq(product)
    expect(order.order_items.first.quantity).to eq(2)

    expect(product.reload.stock_quantity).to eq(3)

    get cart_path
    expect(response.media_type).to eq("application/json")

    cart_json = JSON.parse(response.body)
    expect(cart_json["items"]).to be_empty
    expect(cart_json["total_price"]).to eq(0.0)
  end

  context "when cart is empty" do
    it "returns unprocessable entity" do
      post checkout_cart_path
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context "when quantity exceeds stock" do
    it "returns unprocessable entity" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 10 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
