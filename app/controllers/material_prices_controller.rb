class MaterialPricesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_material
  before_action :set_material_price, only: [:show, :destroy]

  def index
    @material_prices = @material.material_prices.order(effective_date: :desc)
  end

  def show
  end

  def new
    @material_price = @material.material_prices.new
  end

  def create
    @material_price = @material.material_prices.new(material_price_params)

    if @material_price.save
      redirect_to material_material_prices_path(@material), notice: '价格记录创建成功'
    else
      render :new
    end
  end

  def destroy
    @material_price.destroy
    redirect_to material_material_prices_path(@material), notice: '价格记录删除成功'
  end

  private

  def set_material
    @material = Material.find(params[:material_id])
  end

  def set_material_price
    @material_price = @material.material_prices.find(params[:id])
  end

  def material_price_params
    params.require(:material_price).permit(:material_id, :effective_date, :price_per_unit, :currency, :source)
  end
end
