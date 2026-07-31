require 'jwt'

module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from JWT::DecodeError, with: :unauthorized_error

      before_action :authenticate_user!, unless: :devise_controller?

      private

      def authenticate_user!
        token = extract_token_from_header
        if token.blank?
          render json: { error: '未授权访问' }, status: :unauthorized
          return
        end

        begin
          decoded = JwtService.decode(token)
          @current_api_token = ApiToken.active.find_by(id: decoded['token_id'])
          
          if @current_api_token.nil?
            render json: { error: 'Token 已失效' }, status: :unauthorized
            return
          end

          @current_user = @current_api_token.user
        rescue JWT::DecodeError
          render json: { error: '无效的 Token' }, status: :unauthorized
        end
      end

      def devise_controller?
        params[:controller]&.include?('api/v1/auth')
      end

      def current_user
        @current_user
      end

      def extract_token_from_header
        auth_header = request.headers['Authorization']
        return nil unless auth_header

        auth_header.split(' ').last
      end

      def not_found
        render json: { error: '资源不存在' }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { error: exception.message }, status: :unprocessable_entity
      end

      def unauthorized
        render json: { error: '未授权访问' }, status: :unauthorized
      end

      def unauthorized_error(exception)
        render json: { error: exception.message || '未授权访问' }, status: :unauthorized
      end

      def paginate(collection, per_page = 20)
        page = params[:page] || 1
        total = collection.count
        total_pages = (total.to_f / per_page).ceil

        {
          data: collection.limit(per_page).offset((page.to_i - 1) * per_page),
          meta: {
            current_page: page.to_i,
            per_page: per_page,
            total: total,
            total_pages: total_pages
          }
        }
      end
    end
  end
end
