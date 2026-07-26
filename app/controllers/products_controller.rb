class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :edit, :update, :destroy, :publish, :offline, :calculate_price]

  def index
    @categories = Category.all
    @products = Product.includes(:category, :main_material, :variants).order(created_at: :desc)
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
  end

  def show
    @variants = @product.variants
    @batches = @product.batches
    @product_boms = @product.product_boms.includes(:bom_items)
  end

  def new
    @product = Product.new
    @categories = Category.all
    @materials = Material.all
    @design_drawings = DesignDrawing.all
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to products_path, notice: '产品创建成功'
    else
      @categories = Category.all
      @materials = Material.all
      @design_drawings = DesignDrawing.all
      render :new
    end
  end

  def edit
    @categories = Category.all
    @materials = Material.all
    @design_drawings = DesignDrawing.all
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: '产品更新成功'
    else
      @categories = Category.all
      @materials = Material.all
      @design_drawings = DesignDrawing.all
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: '产品删除成功'
  end

  def publish
    @product.publish
    redirect_to products_path, notice: '产品已发布'
  end

  def offline
    @product.offline
    redirect_to products_path, notice: '产品已下架'
  end

  def calculate_price
    @variant = @product.default_variant
    @calculated_price = @variant ? PriceCalculator.calculate(@variant) : nil
    @price_rule = @variant ? PriceRule.match_for(@variant) : nil
    @material = @variant&.material || @product.main_material
    @material_price = @material&.current_price
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :product_code, :category_id, :design_drawing_id, :main_material_id, :base_weight, :description, :status)
  end
end
