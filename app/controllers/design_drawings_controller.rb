class DesignDrawingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @projects = DesignProject.all
    @file_types = DesignDrawing.file_types

    scope = DesignDrawing.includes(:design_project, :drawing_versions)
    scope = scope.where('drawing_code LIKE ? OR name LIKE ?', "%#{params[:keyword]}%", "%#{params[:keyword]}%") if params[:keyword].present?
    scope = scope.where(design_project_id: params[:project_id]) if params[:project_id].present?
    scope = scope.where(file_type: params[:file_type]) if params[:file_type].present?

    @drawings = scope.order(created_at: :desc)
  end

  def show
    @drawing = DesignDrawing.includes(:design_project, :drawing_versions).find(params[:id])
    @versions = @drawing.drawing_versions.order(created_at: :desc)
    @latest_version = @drawing.latest_version
    @latest_draft = @drawing.latest_draft
    @latest_formal = @drawing.latest_formal
  end

  def new
    @drawing = DesignDrawing.new
    @projects = DesignProject.where(status: 'active')
  end

  def create
    @drawing = DesignDrawing.new(drawing_params)
    @drawing.created_by = current_user

    if @drawing.save
      if params[:file].is_a?(ActionDispatch::Http::UploadedFile) && params[:file].original_filename.present?
        version_type = params[:version_type] || 'draft'
        version = @drawing.drawing_versions.new(
          uploaded_by: current_user,
          change_log: '初始版本',
          version_type: version_type
        )
        file = params[:file]
        version.file.attach(io: file, filename: file.original_filename)
        version.save
      end
      redirect_to design_drawing_path(@drawing), notice: '图纸创建成功'
    else
      @projects = DesignProject.where(status: 'active')
      render :new
    end
  end

  def edit
    @drawing = DesignDrawing.find(params[:id])
    @projects = DesignProject.where(status: 'active')
  end

  def update
    @drawing = DesignDrawing.find(params[:id])
    if @drawing.update(drawing_params)
      redirect_to design_drawing_path(@drawing), notice: '图纸更新成功'
    else
      @projects = DesignProject.where(status: 'active')
      render :edit
    end
  end

  def destroy
    @drawing = DesignDrawing.find(params[:id])
    @drawing.destroy
    redirect_to design_drawings_path, notice: '图纸删除成功'
  end

  def upload_version
    @drawing = DesignDrawing.find(params[:design_drawing_id])
    @projects = DesignProject.where(status: 'active')
  end

  def create_version
    @drawing = DesignDrawing.find(params[:design_drawing_id])

    if params[:file].is_a?(ActionDispatch::Http::UploadedFile) && params[:file].original_filename.present?
      version_type = params[:version_type] || 'draft'
      version = @drawing.drawing_versions.new(
        uploaded_by: current_user,
        change_log: params[:change_log],
        version_type: version_type
      )

      file = params[:file]
      version.file.attach(io: file, filename: file.original_filename)

      if version.save
        redirect_to design_drawing_path(@drawing), notice: "版本 #{version.display_version} 上传成功"
      else
        flash[:alert] = "版本上传失败: #{version.errors.full_messages.join(', ')}"
        render :upload_version
      end
    else
      flash[:alert] = '请选择要上传的文件'
      render :upload_version
    end
  end

  def download_version
    @version = DrawingVersion.find(params[:version_id])
    if @version.file.attached?
      redirect_to @version.file_url(expires_in: 24.hours)
    else
      flash[:alert] = '文件不存在'
      redirect_to design_drawing_path(@version.design_drawing)
    end
  end

  def promote_version
    @version = DrawingVersion.find(params[:version_id])
    if @version.is_draft?
      @version.promote_to_formal!
      redirect_to design_drawing_path(@version.design_drawing), notice: "已升级为正式版本 #{@version.display_label}"
    else
      redirect_to design_drawing_path(@version.design_drawing), alert: '只有草稿版本可以升级为正式版本'
    end
  end

  private

  def drawing_params
    params.require(:design_drawing).permit(:name, :description, :file_type, :design_project_id, :drawing_code)
  end
end
