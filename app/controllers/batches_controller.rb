class BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_variant, only: [:index, :new, :create]
  before_action :set_batch, only: [:show, :edit, :update, :destroy, :receive_stock]
  before_action :set_variant_from_batch, only: [:show, :edit, :update, :destroy, :receive_stock]

  def index
    @batches = @variant.batches
  end

  def show
    @serial_numbers = @batch.serial_numbers
  end

  def new
    @batch = @variant.batches.new
    @variants = Variant.all
    @products = Product.all
  end

  def create
    @batch = @variant.batches.new(batch_params)

    if @batch.save
      redirect_to variant_batches_path(@variant), notice: '批次创建成功'
    else
      @variants = Variant.all
      @products = Product.all
      render :new
    end
  end

  def edit
    @variants = Variant.all
    @products = Product.all
  end

  def update
    if @batch.update(batch_params)
      redirect_to variant_batches_path(@batch.variant), notice: '批次更新成功'
    else
      @variants = Variant.all
      @products = Product.all
      render :edit
    end
  end

  def destroy
    variant = @batch.variant
    @batch.destroy
    redirect_to variant_batches_path(variant), notice: '批次删除成功'
  end

  def receive_stock
    @batch.receive_stock(params[:quantity].to_i)
    redirect_to variant_batch_path(@batch.variant, @batch), notice: '入库成功'
  end

  private

  def set_variant
    @variant = Variant.find(params[:variant_id])
  end

  def set_batch
    @batch = Batch.find(params[:id])
  end

  def set_variant_from_batch
    @variant = @batch.variant
  end

  def batch_params
    params.require(:batch).permit(:product_id, :variant_id, :number, :quantity, :production_date, :supplier, :remark, :status)
  end
end
