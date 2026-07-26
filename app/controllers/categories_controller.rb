class CategoriesController < ApplicationController
  before_action :authenticate_user!
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

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :code, :parent_id, :description, :sort_order)
  end
end
