class GuidesController < ApplicationController
  include Pagy::Backend

  before_action :set_guide, only: [:show, :edit, :update, :destroy, :publish, :archive]
  before_action :set_categories, only: [:new, :edit, :create, :update]

  # 公开页面 - 无需登录
  before_action :check_public_access, only: [:index, :show]

  def index
    scope = Guide.published.includes(:guide_category, :author, :product)
                 .order(published_at: :desc)

    scope = scope.by_category(params[:category]) if params[:category].present?
    scope = scope.search(params[:keyword]) if params[:keyword].present?

    @categories = GuideCategory.order(:sort_order)
    @pagy, @guides = pagy(scope, limit: 10)
  end

  def show
    @guide.increment_view!
    @related_guides = Guide.published
                           .where(guide_category_id: @guide.guide_category_id)
                           .where.not(id: @guide.id)
                           .order(published_at: :desc)
                           .limit(5)
  end

  def new
    @guide = Guide.new
    @guide.status = 'draft'
  end

  def create
    @guide = Guide.new(guide_params)
    @guide.author = current_user

    if @guide.save
      redirect_to @guide, notice: '文档创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @guide.update(guide_params)
      redirect_to @guide, notice: '文档更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @guide.destroy
    redirect_to guides_path, notice: '文档已删除'
  end

  def publish
    @guide.publish!
    redirect_to @guide, notice: '文档已发布'
  end

  def archive
    @guide.archive!
    redirect_to @guide, notice: '文档已归档'
  end

  # 管理后台
  def admin
    scope = Guide.includes(:guide_category, :author)
                 .order(updated_at: :desc)

    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.search(params[:keyword]) if params[:keyword].present?

    @categories = GuideCategory.order(:sort_order)
    @pagy, @guides = pagy(scope, limit: 15)
  end

  private

  def set_guide
    slug = params[:slug] || params[:id]
    @guide = Guide.find_by!(slug: slug)
  end

  def set_categories
    @categories = GuideCategory.order(:sort_order)
  end

  def guide_params
    params.require(:guide).permit(
      :title, :content_md, :guide_category_id, :product_id, :status
    )
  end

  def check_public_access
    # 允许访问已发布的文档
    if @guide.present? && !@guide.published?
      authenticate_user!
    end
  end
end
