class CategoriesController < ApplicationController
  PER_PAGE = 12

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to categories_path, alert: "Category not found."
  end

  def index
    @categories = Category.order(:name).page(params[:page]).per(PER_PAGE)
  end

  def show
    @category = Category.find(params[:id])
    @products = @category.products.includes(:reviews, :image_attachment)
                           .order(created_at: :desc)
                           .page(params[:page]).per(PER_PAGE)
  end
end
