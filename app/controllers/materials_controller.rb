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
  end

  def create
    @material = Material.new(material_params)

    if @material.save
      redirect_to materials_path, notice: '材质创建成功'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @material.update(material_params)
      redirect_to materials_path, notice: '材质更新成功'
    else
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
    params.require(:material).permit(:name, :code, :kind, :unit, :density, :description)
  end
end
