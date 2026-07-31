class GuideCategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = GuideCategory.order(:sort_order)
  end

  def new
    @category = GuideCategory.new
  end

  def create
    @category = GuideCategory.new(category_params)
    if @category.save
      redirect_to guide_categories_path, notice: '分类创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to guide_categories_path, notice: '分类更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to guide_categories_path, notice: '分类已删除'
  end

  private

  def set_category
    @category = GuideCategory.find_by!(slug: params[:id])
  end

  def category_params
    params.require(:guide_category).permit(:name, :description, :sort_order)
  end
end
