class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[edit update destroy purge_image purge_gallery_image]

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to admin_products_path, alert: "Product not found."
  end

  def index
    @products = Product.order(created_at: :desc).page(params[:page]).per(20)
  end

  def show; end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_product_path(@product), notice: "Product was successfully created."
    else
      flash.now[:alert] = "Could not create product."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: "Product was successfully updated."
    else
      flash.now[:alert] = "Could not update product."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    Rails.logger.info("Admin user=#{current_user.id} deleted product=#{@product.id}")
    redirect_to admin_products_path, notice: "Product was successfully deleted."
  end

  def purge_image
    if @product.image.attached?
      @product.image.purge_later
      redirect_to edit_admin_product_path(@product), notice: "Primary image removed."
    else
      redirect_to edit_admin_product_path(@product), alert: "No primary image to remove."
    end
  end

  def purge_gallery_image
    image = @product.images.attachments.find_by(id: params[:image_id])
    if image.present?
      image.purge_later
      redirect_to edit_admin_product_path(@product), notice: "Gallery image removed."
    else
      redirect_to edit_admin_product_path(@product), alert: "Gallery image not found."
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :stock_quantity, :category_id,
      :on_sale, :is_new, :recently_updated,
      :image, images: []
    )
  end
end
