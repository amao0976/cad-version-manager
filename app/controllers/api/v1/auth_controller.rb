module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:login]

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          token = ApiToken.create!(
            user: user,
            token: SecureRandom.hex(32),
            expires_at: 2.weeks.from_now
          )

          jwt_token = JwtService.encode(
            user_id: user.id,
            token_id: token.id
          )

          render json: {
            data: {
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role
            },
            token: jwt_token,
            token_type: 'Bearer',
            expires_in: 2.weeks.to_i
          }
        else
          render json: { error: '邮箱或密码错误' }, status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        if current_api_token
          current_api_token.revoke!
        end
        render json: { success: true }
      end

      # GET /api/v1/auth/me
      def me
        render json: {
          data: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.name,
            role: current_user.role
          }
        }
      end

      private

      def current_api_token
        @current_api_token
      end
    end
  end
end
