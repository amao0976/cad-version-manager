module Api
  module V1
    class DesignDrawingsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_design_drawing, only: [:show, :update, :destroy]

      def index
        @drawings = DesignDrawing.all.order(created_at: :desc)
        render json: @drawings, include: [:design_project, :created_by, :latest_version]
      end

      def show
        render json: @drawing, include: [:design_project, :created_by, :drawing_versions, :drawing_approvals]
      end

      def create
        @drawing = DesignDrawing.new(design_drawing_params)
        @drawing.created_by = current_user

        if @drawing.save
          render json: @drawing, status: :created, location: @drawing
        else
          render json: @drawing.errors, status: :unprocessable_entity
        end
      end

      def update
        if @drawing.update(design_drawing_params)
          render json: @drawing
        else
          render json: @drawing.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @drawing.destroy
        head :no_content
      end

      def versions
        @drawing = DesignDrawing.find(params[:design_drawing_id])
        @versions = @drawing.drawing_versions.order(created_at: :desc)
        render json: @versions, include: [:uploaded_by]
      end

      private

      def set_design_drawing
        @drawing = DesignDrawing.find(params[:id])
      end

      def design_drawing_params
        params.require(:design_drawing).permit(:name, :description, :file_type, :design_project_id)
      end
    end
  end
end
