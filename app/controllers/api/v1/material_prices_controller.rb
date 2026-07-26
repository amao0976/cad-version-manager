module Api
  module V1
    class MaterialPricesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_material_price, only: [:show, :destroy]

      def index
        @material_prices = MaterialPrice.all
        @material_prices = @material_prices.where(material_id: params[:material_id]) if params[:material_id]
        @material_prices = @material_prices.order(effective_date: :desc)
        render json: @material_prices
      end

      def show
        render json: @material_price
      end

      def create
        @material_price = MaterialPrice.new(material_price_params)

        if @material_price.save
          render json: @material_price, status: :created
        else
          render json: @material_price.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @material_price.destroy
        head :no_content
      end

      private

      def set_material_price
        @material_price = MaterialPrice.find(params[:id])
      end

      def material_price_params
        params.require(:material_price).permit(:material_id, :price_per_unit, :currency, :effective_date, :source)
      end
    end
  end
end
