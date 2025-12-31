class ProductsController < ApplicationController
  PER_PAGE = 12

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to products_path, alert: "Product not found."
  end

  def index
    @categories = Category.order(:name)

    @products = Product.order(created_at: :desc)

    search_term = params[:search].presence || params[:query].presence
    if search_term.present?
      @products = @products.search(search_term.strip.downcase)
    end

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    case params[:filter]
    when "on_sale"          then @products = @products.on_sale
    when "new"              then @products = @products.new_products
    when "recently_updated" then @products = @products.recently_updated
    end

    @products = @products.includes(:category, :image_attachment)
                         .page(params[:page]).per(PER_PAGE)
  end

  def show
    @product = Product.find(params[:id])
  end
end
