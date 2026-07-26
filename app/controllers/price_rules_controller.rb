class PriceRulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_price_rule, only: [:show, :edit, :update, :destroy]

  def index
    @price_rules = PriceRule.order(created_at: :desc)
  end

  def show
  end

  def new
    @price_rule = PriceRule.new
    @categories = Category.all
    @materials = Material.all
  end

  def create
    @price_rule = PriceRule.new(price_rule_params)

    if @price_rule.save
      redirect_to price_rules_path, notice: '价格规则创建成功'
    else
      @categories = Category.all
      @materials = Material.all
      render :new
    end
  end

  def edit
    @categories = Category.all
    @materials = Material.all
  end

  def update
    if @price_rule.update(price_rule_params)
      redirect_to price_rules_path, notice: '价格规则更新成功'
    else
      @categories = Category.all
      @materials = Material.all
      render :edit
    end
  end

  def destroy
    @price_rule.destroy
    redirect_to price_rules_path, notice: '价格规则删除成功'
  end

  private

  def set_price_rule
    @price_rule = PriceRule.find(params[:id])
  end

  def price_rule_params
    params.require(:price_rule).permit(:name, :category_id, :material_id, :labor_cost, :markup_rate, :effective_from, :effective_to, :active, :remark)
  end
end
