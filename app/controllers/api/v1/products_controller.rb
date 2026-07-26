module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_product, only: [:show, :update, :destroy, :publish, :offline, :calculate_price]

      def index
        @products = Product.order(created_at: :desc)
        render json: @products, include: [:variants, :batches]
      end

      def show
        render json: @product, include: [:variants, :batches]
      end

      def create
        @product = Product.new(product_params)

        if @product.save
          render json: @product, status: :created
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          render json: @product
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @product.destroy
        head :no_content
      end

      def publish
        @product.publish
        render json: @product
      end

      def offline
        @product.offline
        render json: @product
      end

      def calculate_price
        @price = @product.calculate_price
        render json: { product_id: @product.id, calculated_price: @price }
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:name, :product_code, :category_id, :design_drawing_id, :main_material_id, :base_weight, :description, :status)
      end
    end
  end
end
