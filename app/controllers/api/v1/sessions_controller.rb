module Api
  module V1
    class SessionsController < ActionController::API
      def create
        user = User.find_by(email: params[:email].to_s.downcase)

        if user&.valid_password?(params[:password])
          render json: {
            token: user.ensure_api_token!,
            user: {
              id: user.id,
              email: user.email
            }
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        token = request.headers["Authorization"].to_s.remove("Bearer ").strip
        user = User.find_by(api_token: token)

        if user
          user.update!(api_token: nil)
          render json: { message: "Logged out" }, status: :ok
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end
