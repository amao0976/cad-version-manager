class DesignProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @design_projects = DesignProject.all.order(created_at: :desc)
  end

  def show
    @design_project = DesignProject.find(params[:id])
    @drawings = @design_project.design_drawings
  end
end
