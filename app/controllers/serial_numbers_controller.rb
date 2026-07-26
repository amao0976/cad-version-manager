class SerialNumbersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_serial_number, only: [:show, :edit, :update, :destroy, :sell, :return_item, :scrap]

  def index
    @serial_numbers = SerialNumber.all.order(created_at: :desc)
    @serial_numbers = @serial_numbers.where(variant_id: params[:variant_id]) if params[:variant_id].present?
    @serial_numbers = @serial_numbers.where(batch_id: params[:batch_id]) if params[:batch_id].present?
    @serial_numbers = @serial_numbers.where('code LIKE ?', "%#{params[:code]}%") if params[:code].present?
  end

  def show
  end

  def new
    @serial_number = SerialNumber.new
    @serial_number.batch_id = params[:batch_id] if params[:batch_id].present?
    @variants = Variant.all
    @batches = Batch.all
  end

  def create
    @serial_number = SerialNumber.new(serial_number_params)

    if @serial_number.save
      if params[:batch_id].present?
        redirect_to variant_batch_path(@serial_number.batch.variant, @serial_number.batch), notice: '序列号创建成功'
      else
        redirect_to serial_numbers_path, notice: '序列号创建成功'
      end
    else
      @variants = Variant.all
      @batches = Batch.all
      render :new
    end
  end

  def edit
    @variants = Variant.all
    @batches = Batch.all
  end

  def update
    if @serial_number.update(serial_number_params)
      redirect_to serial_numbers_path, notice: '序列号更新成功'
    else
      @variants = Variant.all
      @batches = Batch.all
      render :edit
    end
  end

  def destroy
    @serial_number.destroy
    redirect_to serial_numbers_path, notice: '序列号删除成功'
  end

  def sell
    @serial_number.sell
    redirect_to serial_numbers_path, notice: '序列号已售出'
  end

  def return_item
    @serial_number.return_item
    redirect_to serial_numbers_path, notice: '序列号已退回'
  end

  def scrap
    @serial_number.scrap
    redirect_to serial_numbers_path, notice: '序列号已报废'
  end

  private

  def set_serial_number
    @serial_number = SerialNumber.find(params[:id])
  end

  def serial_number_params
    params.require(:serial_number).permit(:variant_id, :batch_id, :code, :certificate_no, :status, :sold_at)
  end
end
