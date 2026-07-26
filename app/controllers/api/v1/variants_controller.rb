module Api
  module V1
    class VariantsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_variant, only: [:show, :update, :destroy]

      def index
        @variants = Variant.all
        @variants = @variants.where(product_id: params[:product_id]) if params[:product_id]
        @variants = @variants.order(created_at: :desc)
        render json: @variants
      end

      def show
        render json: @variant
      end

      def create
        @variant = Variant.new(variant_params)

        if @variant.save
          render json: @variant, status: :created
        else
          render json: @variant.errors, status: :unprocessable_entity
        end
      end

      def update
        if @variant.update(variant_params)
          render json: @variant
        else
          render json: @variant.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @variant.destroy
        head :no_content
      end

      private

      def set_variant
        @variant = Variant.find(params[:id])
      end

      def variant_params
        params.require(:variant).permit(:product_id, :sku_code, :material_id, :size, :color, :gemstone, :weight, :status, :description)
      end
    end
  end
end
