module Api
  module V1
    class DesignProjectsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_design_project, only: [:show, :update, :destroy]

      def index
        @projects = DesignProject.all.order(created_at: :desc)
        render json: @projects, include: [:design_drawings]
      end

      def show
        render json: @project, include: [:design_drawings, :created_by]
      end

      def create
        @project = DesignProject.new(design_project_params)
        @project.created_by = current_user
        @project.status = 'active'

        if @project.save
          render json: @project, status: :created, location: @project
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def update
        if @project.update(design_project_params)
          render json: @project
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @project.destroy
        head :no_content
      end

      private

      def set_design_project
        @project = DesignProject.find(params[:id])
      end

      def design_project_params
        params.require(:design_project).permit(:name, :description, :status)
      end
    end
  end
end
