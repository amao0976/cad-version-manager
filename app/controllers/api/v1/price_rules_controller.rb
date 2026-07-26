module Api
  module V1
    class PriceRulesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_price_rule, only: [:show, :update, :destroy]

      def index
        @price_rules = PriceRule.order(created_at: :desc)
        render json: @price_rules
      end

      def show
        render json: @price_rule
      end

      def create
        @price_rule = PriceRule.new(price_rule_params)

        if @price_rule.save
          render json: @price_rule, status: :created
        else
          render json: @price_rule.errors, status: :unprocessable_entity
        end
      end

      def update
        if @price_rule.update(price_rule_params)
          render json: @price_rule
        else
          render json: @price_rule.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @price_rule.destroy
        head :no_content
      end

      private

      def set_price_rule
        @price_rule = PriceRule.find(params[:id])
      end

      def price_rule_params
        params.require(:price_rule).permit(:name, :category_id, :material_id, :labor_cost, :markup_rate, :effective_from, :effective_to, :active, :remark)
      end
    end
  end
end
