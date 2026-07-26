module Api
  module V1
    class ProductBomsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_product_bom, only: [:show, :update, :destroy, :approve, :release, :archive]

      def index
        @product_boms = ProductBom.includes(:design_drawing, :bom_items).order(created_at: :desc)
        render json: @product_boms
      end

      def show
        render json: @product_bom, include: [:bom_items, :design_drawing]
      end

      def create
        @product_bom = ProductBom.new(product_bom_params)
        @product_bom.created_by = current_user

        if @product_bom.save
          render json: @product_bom, status: :created
        else
          render json: @product_bom.errors, status: :unprocessable_entity
        end
      end

      def update
        if @product_bom.update(product_bom_params)
          render json: @product_bom
        else
          render json: @product_bom.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @product_bom.destroy
        head :no_content
      end

      def approve
        @product_bom.approve
        render json: @product_bom
      end

      def release
        @product_bom.release
        render json: @product_bom
      end

      def archive
        @product_bom.archive
        render json: @product_bom
      end

      private

      def set_product_bom
        @product_bom = ProductBom.find(params[:id])
      end

      def product_bom_params
        params.require(:product_bom).permit(:design_project_id, :design_drawing_id, :name, :description, :revision, :status)
      end
    end
  end
end