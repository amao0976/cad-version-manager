module Api
  module V1
    class BomItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_bom_item, only: [:show, :update, :destroy]

      def index
        @bom_items = BomItem.includes(:design_drawing, :sub_items).order(level: :asc, part_number: :asc)
        render json: @bom_items
      end

      def show
        render json: @bom_item, include: [:design_drawing, :sub_items]
      end

      def create
        @bom_item = BomItem.new(bom_item_params)

        if @bom_item.save
          render json: @bom_item, status: :created
        else
          render json: @bom_item.errors, status: :unprocessable_entity
        end
      end

      def update
        if @bom_item.update(bom_item_params)
          render json: @bom_item
        else
          render json: @bom_item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @bom_item.destroy
        head :no_content
      end

      private

      def set_bom_item
        @bom_item = BomItem.find(params[:id])
      end

      def bom_item_params
        params.require(:bom_item).permit(
          :product_bom_id, :design_drawing_id, :part_number, :part_name,
          :material, :specification, :quantity, :unit, :weight, :source, :level, :parent_id
        )
      end
    end
  end
end