class Admin::ProvincesController < Admin::BaseController
  before_action :set_province, only: %i[edit update destroy]

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to admin_provinces_path, alert: "Province not found."
  end

  def index
    @provinces = Province.order(:name).page(params[:page]).per(20)
  end

  def new
    @province = Province.new
  end

  def create
    @province = Province.new(province_params)
    if @province.save
      redirect_to admin_provinces_path, notice: "Province was successfully created."
    else
      flash.now[:alert] = "Could not create province."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @province.update(province_params)
      redirect_to admin_provinces_path, notice: "Province was successfully updated."
    else
      flash.now[:alert] = "Could not update province."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @province.destroy
    Rails.logger.info("Admin user=#{current_user.id} deleted province=#{@province.id}")
    redirect_to admin_provinces_path, notice: "Province was successfully deleted."
  end

  private

  def set_province
    @province = Province.find(params[:id])
  end

  def province_params
    params.require(:province).permit(:name, :gst, :pst, :hst)
  end
end
