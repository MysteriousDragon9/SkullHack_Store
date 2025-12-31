class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_review, only: :destroy

  def create
    @review = @product.reviews.build(review_params.merge(user: current_user))

    if @review.save
      redirect_to @product, notice: "Review added."
    else
      flash.now[:alert] = "Could not add review."
      render "products/show", status: :unprocessable_entity
    end
  end

  def destroy
    if @review.user == current_user || current_user.admin?
      @review.destroy
      redirect_to @product, notice: "Review deleted."
    else
      redirect_to @product, alert: "You are not authorized to delete this review."
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Product not found."
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Review not found."
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
