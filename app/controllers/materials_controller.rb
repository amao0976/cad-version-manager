class MaterialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_material, only: [:show, :edit, :update, :destroy]

  def index
    @materials = Material.all.group_by(&:kind)
  end

  def show
    @price_history = @material.material_prices.order(effective_date: :desc)
  end

  def new
    @material = Material.new
    load_case_material_categories
  end

  def create
    @material = Material.new(material_params)

    if @material.save
      redirect_to materials_path, notice: '材质创建成功'
    else
      load_case_material_categories
      render :new
    end
  end

  def edit
    load_case_material_categories
  end

  def update
    if @material.update(material_params)
      redirect_to materials_path, notice: '材质更新成功'
    else
      load_case_material_categories
      render :edit
    end
  end

  def destroy
    @material.destroy
    redirect_to materials_path, notice: '材质删除成功'
  end

  private

  def set_material
    @material = Material.find(params[:id])
  end

  def material_params
    params.require(:material).permit(:name, :code, :kind, :unit, :density, :description, :case_material_category_id)
  end

  def load_case_material_categories
    # L2 表壳材质选项
    material_parent = Category.find_by(code: 'MATERIAL')
    @case_material_categories = material_parent ? material_parent.children.order(:sort_order) : []
  end
end
