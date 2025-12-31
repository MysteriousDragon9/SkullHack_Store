class Admin::DashboardController < Admin::BaseController
  def index
    @products_count   = Product.count
    @orders_count     = Order.count
    @categories_count = Category.count
    @users_count      = User.count
    @recent_orders    = Order.order(created_at: :desc).limit(5)
    @total_revenue    = Order.sum(:grand_total)
  end
end
