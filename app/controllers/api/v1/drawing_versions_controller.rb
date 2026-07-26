module Api
  module V1
    class DrawingVersionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_drawing_version, only: [:show, :destroy, :download]

      def index
        @versions = DrawingVersion.all.order(created_at: :desc)
        render json: @versions, include: [:design_drawing, :uploaded_by]
      end

      def show
        render json: @version, include: [:design_drawing, :uploaded_by, :drawing_approvals]
      end

      def create
        @drawing = DesignDrawing.find(params[:design_drawing_id])
        @version = DrawingVersion.new(drawing_version_params)
        @version.design_drawing = @drawing
        @version.uploaded_by = current_user
        @version.file_size = params[:file].size if params[:file]

        if @version.save
          render json: @version, status: :created, location: @version
        else
          render json: @version.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @version.destroy
        head :no_content
      end

      def download
        if @version.file.attached?
          redirect_to rails_blob_url(@version.file, disposition: 'attachment')
        else
          render json: { error: 'File not found' }, status: :not_found
        end
      end

      def latest
        @drawing = DesignDrawing.find(params[:design_drawing_id])
        @version = @drawing.latest_version
        if @version
          render json: @version, include: [:uploaded_by]
        else
          render json: { error: 'No versions found' }, status: :not_found
        end
      end

      private

      def set_drawing_version
        @version = DrawingVersion.find(params[:id])
      end

      def drawing_version_params
        params.require(:drawing_version).permit(:change_log, :version_number, :file)
      end
    end
  end
end
