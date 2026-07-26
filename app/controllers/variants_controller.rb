class VariantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:index, :new, :create]
  before_action :set_variant, only: [:show, :edit, :update, :destroy]
  before_action :set_product_from_variant, only: [:show, :edit, :update, :destroy]

  def index
    @variants = @product.variants
  end

  def show
    @batches = @variant.batches
    @serial_numbers = @variant.serial_numbers
  end

  def new
    @variant = @product.variants.new
    @products = Product.all
    @materials = Material.all
  end

  def create
    @variant = @product.variants.new(variant_params)

    if @variant.save
      redirect_to product_variants_path(@product), notice: '变体创建成功'
    else
      @products = Product.all
      @materials = Material.all
      render :new
    end
  end

  def edit
    @products = Product.all
    @materials = Material.all
  end

  def update
    if @variant.update(variant_params)
      redirect_to product_variants_path(@variant.product), notice: '变体更新成功'
    else
      @products = Product.all
      @materials = Material.all
      render :edit
    end
  end

  def destroy
    product = @variant.product
    @variant.destroy
    redirect_to product_variants_path(product), notice: '变体删除成功'
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_variant
    @variant = Variant.find(params[:id])
  end

  def set_product_from_variant
    @product = @variant.product
  end

  def variant_params
    params.require(:variant).permit(:product_id, :sku_code, :material_id, :size, :color, :gemstone, :weight, :status, :description)
  end
end
