module Api
  module V1
    class Controller < Api::Controller
      before_action :authenticate_user!
      before_action :set_default_response_format

      private

      def set_default_response_format
        request.format = :json
      end
    end
  end
end