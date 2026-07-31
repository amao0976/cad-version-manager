class PlmController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    # 产品生命周期统计
    @lifecycle_stats = Product.lifecycle_states.values.map do |state|
      [Product.lifecycle_states.key(state), Product.where(lifecycle_state: state).count]
    end

    # 各状态产品列表
    @products_by_state = Product.lifecycle_states.values.map do |state|
      [state, Product.where(lifecycle_state: state).includes(:category).order(:lifecycle_updated_at)]
    end

    # 最近生命周期变更
    @recent_lifecycle_changes = LifecycleHistory.includes(:product, :changed_by).order(created_at: :desc).limit(10)

    # 文档统计
    @document_stats = Document.statuses.values.map do |status|
      [Document.statuses.key(status), Document.where(status: status).count]
    end

    # 最近文档变更
    @recent_documents = Document.includes(:product, :created_by).order(updated_at: :desc).limit(10)

    # 待审批文档
    @pending_documents = Document.joins(:document_versions).where(document_versions: { status: 'submitted' }).distinct

    # BOM 审批状态统计
    @bom_stats = {
      'draft' => ProductBom.where(status: 'draft').count,
      'submitted' => ProductBom.where(status: 'submitted').count,
      'approved' => ProductBom.where(status: 'approved').count,
      'released' => ProductBom.where(status: 'released').count
    }

    # 图纸版本统计
    @drawing_stats = {
      'total' => DesignDrawing.count,
      'with_versions' => DesignDrawing.joins(:drawing_versions).distinct.count
    }

    # 验货统计
    @inspection_stats = {
      'total_requests' => Inspection::Request.count,
      'pending_requests' => Inspection::Request.where(status: 'pending').count,
      'total_records' => Inspection::Record.count,
      'passed' => Inspection::Record.where(result: 'pass').count,
      'failed' => Inspection::Record.where(result: 'fail').count
    }

    # 最近验货记录
    @recent_inspections = Inspection::Record.includes(:product, :supplier).order(created_at: :desc).limit(5)
  end
end
