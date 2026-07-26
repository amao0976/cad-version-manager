module Api
  module V1
    class MaterialsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_material, only: [:show, :update, :destroy]

      def index
        @materials = Material.order(created_at: :desc)
        render json: @materials, include: [:material_prices]
      end

      def show
        render json: @material, include: [:material_prices]
      end

      def create
        @material = Material.new(material_params)

        if @material.save
          render json: @material, status: :created
        else
          render json: @material.errors, status: :unprocessable_entity
        end
      end

      def update
        if @material.update(material_params)
          render json: @material
        else
          render json: @material.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @material.destroy
        head :no_content
      end

      private

      def set_material
        @material = Material.find(params[:id])
      end

      def material_params
        params.require(:material).permit(:name, :code, :kind, :unit, :density, :description)
      end
    end
  end
end
