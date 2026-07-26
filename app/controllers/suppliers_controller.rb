class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  def index
    @suppliers = Supplier.all.order(created_at: :desc)
    @suppliers = @suppliers.where(supplier_type: params[:supplier_type]) if params[:supplier_type].present?
    @suppliers = @suppliers.where(status: params[:status]) if params[:status].present?
    @suppliers = @suppliers.where(level: params[:level]) if params[:level].present?
    if params[:keyword].present?
      kw = "%#{params[:keyword]}%"
      @suppliers = @suppliers.where('name LIKE ? OR code LIKE ? OR contact_person LIKE ? OR phone LIKE ?', kw, kw, kw, kw)
    end
  end

  def show
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)
    if @supplier.save
      redirect_to suppliers_path, notice: '供应商创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to suppliers_path, notice: '供应商更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @supplier.destroy
    redirect_to suppliers_path, notice: '供应商删除成功'
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(
      :name, :code, :short_name, :supplier_type, :contact_person, :phone,
      :email, :address, :bank_name, :bank_account, :tax_number,
      :status, :level, :remark
    )
  end
end
