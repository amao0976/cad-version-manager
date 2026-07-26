module Api
  module V1
    class BatchesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_batch, only: [:show, :update, :destroy, :receive_stock]

      def index
        @batches = Batch.all
        @batches = @batches.where(variant_id: params[:variant_id]) if params[:variant_id]
        @batches = @batches.order(created_at: :desc)
        render json: @batches
      end

      def show
        render json: @batch
      end

      def create
        @batch = Batch.new(batch_params)

        if @batch.save
          render json: @batch, status: :created
        else
          render json: @batch.errors, status: :unprocessable_entity
        end
      end

      def update
        if @batch.update(batch_params)
          render json: @batch
        else
          render json: @batch.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @batch.destroy
        head :no_content
      end

      def receive_stock
        @batch.receive_stock(params[:quantity].to_i)
        render json: @batch
      end

      private

      def set_batch
        @batch = Batch.find(params[:id])
      end

      def batch_params
        params.require(:batch).permit(:product_id, :variant_id, :number, :quantity, :production_date, :supplier, :status, :remark)
      end
    end
  end
end
