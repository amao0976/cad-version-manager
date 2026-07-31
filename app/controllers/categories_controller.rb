class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy, :import, :do_import, :export]
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.where(parent_id: nil).order(sort_order: :asc, created_at: :desc)
  end

  def show
    @sub_categories = @category.children
    @products = @category.products
  end

  def new
    @category = Category.new
    @categories = Category.all
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: '分类创建成功'
    else
      @categories = Category.all
      render :new
    end
  end

  def edit
    @categories = Category.all
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: '分类更新成功'
    else
      @categories = Category.all
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: '分类删除成功'
  end

  def import
  end

  def do_import
    unless params[:csv_file].present?
      redirect_to categories_import_path, alert: '请选择 CSV 文件'
      return
    end

    @import_service = CategoryImportService.new(params[:csv_file])
    @import_service.call

    if @import_service.success?
      redirect_to categories_path,
                  notice: "导入成功！新增 #{@import_service.imported_count} 条，更新 #{@import_service.updated_count} 条"
    else
      @errors = @import_service.errors
      render :import, status: :unprocessable_entity
    end
  end

  def export
    csv_data = CategoryImportService.export
    send_data "\uFEFF#{csv_data}", filename: "categories_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv", type: 'text/csv'
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :code, :parent_id, :description, :sort_order)
  end
end
