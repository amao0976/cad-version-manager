class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :edit, :update, :destroy, :publish, :offline, :calculate_price, :transition]

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
    load_watch_categories
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to products_path, notice: '产品创建成功'
    else
      @categories = Category.all
      @materials = Material.all
      @design_drawings = DesignDrawing.all
      load_watch_categories
      render :new
    end
  end

  def edit
    @categories = Category.all
    @materials = Material.all
    @design_drawings = DesignDrawing.all
    load_watch_categories
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: '产品更新成功'
    else
      @categories = Category.all
      @materials = Material.all
      @design_drawings = DesignDrawing.all
      load_watch_categories
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

  def transition
    to_state = params[:to_state]
    remark = params[:remark]

    if @product.transition_to!(to_state, current_user, remark)
      redirect_to @product, notice: "产品状态已变更为「#{Product.lifecycle_states.key(to_state)}」"
    else
      redirect_to @product, alert: '状态变更失败，当前状态不允许此转换'
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    allowed = [
      :name, :product_code, :category_id, :design_drawing_id,
      :base_weight, :description, :status, :theme,
      :movement_category_id, :strap_category_id, :target_group_category_id,
      product_images_attributes: [
        :id, :image, :position, :is_cover, :_destroy
      ]
    ]
    params.require(:product).permit(allowed)
  end

  def load_watch_categories
    # L1 机芯类型（WATCH 下的直接子分类中，非属性分组的）
    watch_root = Category.find_by(code: 'WATCH')
    @movement_categories = watch_root ? watch_root.children.where.not(code: ['MATERIAL', 'STRAP', 'TARGET_GROUP']).order(:sort_order) : []
    # L2 表带类型选项
    strap_parent = Category.find_by(code: 'STRAP')
    @strap_categories = strap_parent ? strap_parent.children.order(:sort_order) : []
    # L2 目标人群选项
    target_parent = Category.find_by(code: 'TARGET_GROUP')
    @target_group_categories = target_parent ? target_parent.children.order(:sort_order) : []
  end
end