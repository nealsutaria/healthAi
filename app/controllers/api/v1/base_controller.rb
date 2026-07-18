module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      attr_reader :current_user

      private

      def authenticate_api_user!
        token = request.headers["Authorization"].to_s.remove("Bearer ").strip

        @current_user = User.find_by(api_token: token)

        unless @current_user
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end
