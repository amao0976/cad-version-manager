class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    if user_signed_in?
      redirect_to dashboard_path
    end
  end

  def dashboard
    @projects = DesignProject.all
    @drawings = DesignDrawing.all
    @versions = DrawingVersion.all
    @boms = ProductBom.all
    @categories = Category.where(parent_id: nil).order(:sort_order)
    @suppliers = Supplier.all
    @products = Product.all
  end
end