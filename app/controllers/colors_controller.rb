class ColorsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy, :import, :do_import]
  before_action :set_color, only: [:show, :edit, :update, :destroy]

  def index
    @colors = Color.order(created_at: :desc)
    @colors = @colors.where(color_type: params[:color_type]) if params[:color_type].present?
    @colors = @colors.where('name LIKE :q OR code LIKE :q', q: "%#{params[:keyword]}%") if params[:keyword].present?
  end

  def show
  end

  def new
    @color = Color.new
  end

  def create
    @color = Color.new(color_params)
    if @color.save
      redirect_to colors_path, notice: '颜色创建成功'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @color.update(color_params)
      redirect_to colors_path, notice: '颜色更新成功'
    else
      render :edit
    end
  end

  def destroy
    @color.destroy
    redirect_to colors_path, notice: '颜色删除成功'
  end

  def import
  end

  def do_import
    unless params[:csv_file].present?
      redirect_to import_colors_path, alert: '请选择 CSV 文件'
      return
    end

    @import_service = ColorImportService.new(params[:csv_file])
    @import_service.call

    if @import_service.success?
      redirect_to colors_path,
                  notice: "导入成功！新增 #{@import_service.imported_count} 条，更新 #{@import_service.updated_count} 条"
    else
      @errors = @import_service.errors
      render :import, status: :unprocessable_entity
    end
  end

  private

  def set_color
    @color = Color.find(params[:id])
  end

  def color_params
    params.require(:color).permit(:name, :code, :color_type, :hex_code, :description, :active)
  end
end
