class Admin::PagesController < Admin::BaseController
  before_action :set_page, only: %i[show edit update destroy]

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to admin_pages_path, alert: "Page not found."
  end

  def index
    @pages = Page.order(:slug).page(params[:page]).per(20)
  end

  def show; end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    if @page.save
      redirect_to admin_page_path(@page), notice: "Page was successfully created."
    else
      flash.now[:alert] = "Could not create page."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @page.update(page_params)
      redirect_to admin_page_path(@page), notice: "Page was successfully updated."
    else
      flash.now[:alert] = "Could not update page."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page.destroy
    Rails.logger.info("Admin user=#{current_user.id} deleted page=#{@page.id}")
    redirect_to admin_pages_path, notice: "Page was successfully deleted."
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :content, :slug)
  end
end
