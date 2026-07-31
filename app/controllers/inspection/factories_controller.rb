module Inspection
  class FactoriesController < BaseController
    before_action :set_supplier, only: [:index, :create]

    def index
      @factories = Factory.includes(:supplier).order(:supplier_id, :name)
      @factories = @factories.where(supplier_id: @supplier.id) if @supplier
      @factories = @factories.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present? && !@supplier

      respond_to do |format|
        format.html
        format.json { render json: @factories.map { |f| { id: f.id, name: f.name, country: f.country, province: f.province, city: f.city, address: f.address, remarks: f.remarks } } }
      end
    end

    def create
      supplier = @supplier || Supplier.find(factory_params[:supplier_id])
      @factory = Factory.new(factory_params.merge(supplier_id: supplier.id))
      if @factory.save
        redirect_to factories_path(supplier_id: supplier.id), notice: '工厂创建成功'
      else
        @factories = Factory.order(:name)
        render :index, status: :unprocessable_entity
      end
    end

    def update
      @factory = Factory.find(params[:id])
      if @factory.update(factory_params)
        redirect_to factories_path, notice: '工厂更新成功'
      else
        @factories = Factory.order(:name)
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      @factory = Factory.find(params[:id])
      @factory.destroy
      redirect_to factories_path, notice: '工厂已删除'
    end

    private

    def set_supplier
      @supplier = Supplier.find(params[:supplier_id]) if params[:supplier_id].present?
    end

    def factory_params
      params.require(:factory).permit(:supplier_id, :name, :address, :city, :province, :country, :remarks)
    end
  end
end
