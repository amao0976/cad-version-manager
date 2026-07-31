class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_engineer, only: [:new, :create, :edit, :update, :destroy, :upload_version, :submit_version, :approve_version, :release_version]
  before_action :set_document, only: [:show, :edit, :update, :destroy, :upload_version, :submit_version, :approve_version, :release_version, :download]

  def index
    @documents = Document.includes(:product, :created_by).order(updated_at: :desc)
    @documents = @documents.where(doc_type: params[:doc_type]) if params[:doc_type].present?
    @documents = @documents.where(status: params[:status]) if params[:status].present?
  end

  def show
    @versions = @document.document_versions.order(created_at: :desc)
  end

  def new
    @document = Document.new
    @products = Product.order(:name)
  end

  def create
    @document = Document.new(document_params)
    @document.created_by = current_user

    if @document.save
      redirect_to @document, notice: '文档创建成功'
    else
      @products = Product.order(:name)
      render :new
    end
  end

  def edit
    @products = Product.order(:name)
  end

  def update
    if @document.update(document_params)
      redirect_to @document, notice: '文档更新成功'
    else
      @products = Product.order(:name)
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: '文档已删除'
  end

  # 上传新版本
  def upload_version
    unless params[:file].present?
      redirect_to @document, alert: '请选择文件'
      return
    end

    version_number = params[:version].present? ? params[:version] : next_version_number(@document)

    @version = @document.document_versions.new(
      version: version_number,
      uploaded_by: current_user,
      change_summary: params[:change_summary]
    )
    @version.file.attach(params[:file])

    if @version.save
      @document.update(current_version: version_number)
      redirect_to @document, notice: "版本 #{version_number} 上传成功"
    else
      redirect_to @document, alert: "版本上传失败: #{@version.errors.full_messages.join(', ')}"
    end
  end

  # 提交审批
  def submit_version
    version = @document.document_versions.find(params[:version_id])
    if version.submit!(current_user)
      redirect_to @document, notice: "版本 #{version.version} 已提交审批"
    else
      redirect_to @document, alert: '版本提交失败，当前状态不允许此操作'
    end
  end

  # 审批通过
  def approve_version
    version = @document.document_versions.find(params[:version_id])
    if version.approve!(current_user)
      redirect_to @document, notice: "版本 #{version.version} 审批通过"
    else
      redirect_to @document, alert: '审批失败，当前状态不允许此操作'
    end
  end

  # 发布
  def release_version
    version = @document.document_versions.find(params[:version_id])
    if version.release!(current_user)
      redirect_to @document, notice: "版本 #{version.version} 已发布"
    else
      redirect_to @document, alert: '发布失败，当前状态不允许此操作'
    end
  end

  # 下载文件
  def download
    version = @document.document_versions.find(params[:version_id])
    if version.file.attached?
      redirect_to rails_blob_path(version.file, disposition: 'attachment')
    else
      redirect_to @document, alert: '该版本没有附件'
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :doc_number, :doc_type, :product_id, :design_drawing_id, :description)
  end

  def next_version_number(document)
    latest = document.document_versions.order(created_at: :desc).first
    return '0.1' unless latest

    major, minor = latest.version.split('.').map(&:to_i)
    "#{major}.#{minor + 1}"
  end

  def require_admin_or_engineer
    unless current_user.admin? || current_user.engineer?
      redirect_to documents_path, alert: '您没有权限执行此操作'
    end
  end
end
