module Api
  module V1
    class SerialNumbersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_serial_number, only: [:show, :update, :destroy, :sell, :return_item, :scrap]

      def index
        @serial_numbers = SerialNumber.all
        @serial_numbers = @serial_numbers.where(variant_id: params[:variant_id]) if params[:variant_id]
        @serial_numbers = @serial_numbers.where('code LIKE ?', "%#{params[:code]}%") if params[:code].present?
        @serial_numbers = @serial_numbers.order(created_at: :desc)
        render json: @serial_numbers
      end

      def show
        render json: @serial_number
      end

      def create
        @serial_number = SerialNumber.new(serial_number_params)

        if @serial_number.save
          render json: @serial_number, status: :created
        else
          render json: @serial_number.errors, status: :unprocessable_entity
        end
      end

      def update
        if @serial_number.update(serial_number_params)
          render json: @serial_number
        else
          render json: @serial_number.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @serial_number.destroy
        head :no_content
      end

      def sell
        @serial_number.sell
        render json: @serial_number
      end

      def return_item
        @serial_number.return_item
        render json: @serial_number
      end

      def scrap
        @serial_number.scrap
        render json: @serial_number
      end

      private

      def set_serial_number
        @serial_number = SerialNumber.find(params[:id])
      end

      def serial_number_params
        params.require(:serial_number).permit(:variant_id, :batch_id, :code, :certificate_no, :status, :sold_at)
      end
    end
  end
end
