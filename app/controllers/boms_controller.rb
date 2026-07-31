class BomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.where(parent_id: nil).order(:sort_order)
    @products = Product.all
    @boms = ProductBom.includes(:design_project, :design_drawing, :bom_items, product: :category).order(created_at: :desc)
    @boms = @boms.where(product_id: params[:product_id]) if params[:product_id].present?
    @boms = @boms.where(status: params[:status]) if params[:status].present?
    if params[:category_id].present?
      cat = Category.find(params[:category_id])
      @boms = @boms.where(product_id: Product.where(category_id: cat.self_and_descendants.pluck(:id)))
    end
    if params[:keyword].present?
      kw = "%#{params[:keyword]}%"
      @boms = @boms.where('name LIKE ? OR revision LIKE ?', kw, kw)
    end
  end

  def show
    @bom = ProductBom.includes(bom_items: [:design_drawing, :sub_items, :color]).find(params[:id])
  end

  def new
    @bom = ProductBom.new
    @projects = DesignProject.all
    @drawings = DesignDrawing.all
    @products = Product.all
  end

  def create
    @bom = ProductBom.new(bom_params)
    @bom.created_by = current_user

    if @bom.save
      redirect_to boms_path, notice: 'BOM创建成功'
    else
      @projects = DesignProject.all
      @drawings = DesignDrawing.all
      @products = Product.all
      render :new
    end
  end

  def edit
    @bom = ProductBom.find(params[:id])
    @projects = DesignProject.all
    @drawings = DesignDrawing.all
    @products = Product.all
  end

  def update
    @bom = ProductBom.find(params[:id])
    if @bom.update(bom_params)
      redirect_to boms_path, notice: 'BOM更新成功'
    else
      @projects = DesignProject.all
      @drawings = DesignDrawing.all
      @products = Product.all
      render :edit
    end
  end

  def destroy
    @bom = ProductBom.find(params[:id])
    @bom.destroy
    redirect_to boms_path, notice: 'BOM删除成功'
  end

  def approve
    @bom = ProductBom.find(params[:bom_id])
    @bom.approve
    redirect_to boms_path, notice: 'BOM已审批'
  end

  def release
    @bom = ProductBom.find(params[:bom_id])
    @bom.release
    redirect_to boms_path, notice: 'BOM已发布'
  end

  def add_item
    @bom = ProductBom.find(params[:bom_id])
    @item = BomItem.new(product_bom_id: @bom.id)
    @drawings = DesignDrawing.all
    @colors = Color.active.order(:color_type, :name)
  end

  def create_item
    @bom = ProductBom.find(params[:bom_id])
    @item = @bom.bom_items.new(item_params)

    if @item.save
      redirect_to bom_path(@bom), notice: '物料项添加成功'
    else
      @drawings = DesignDrawing.all
      @colors = Color.active.order(:color_type, :name)
      render :add_item
    end
  end

  def delete_item
    @item = BomItem.find(params[:item_id])
    @bom = @item.product_bom
    @item.destroy
    redirect_to bom_path(@bom), notice: '物料项删除成功'
  end

  private

  def bom_params
    params.require(:product_bom).permit(:design_project_id, :design_drawing_id, :product_id, :name, :description, :revision, :status)
  end

  def item_params
    params.require(:bom_item).permit(
      :design_drawing_id, :part_number, :part_name, :material, :specification,
      :quantity, :unit, :weight, :source, :level, :parent_id, :color_id
    )
  end
end