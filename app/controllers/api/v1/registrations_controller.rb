# app/controllers/api/v1/registrations_controller.rb

module Api
  module V1
    class RegistrationsController < ActionController::API
      def create
        user = User.new(user_params)

        if user.save
          user.ensure_api_token!

          render json: {
            token: user.api_token,
            user: {
              id: user.id,
              email: user.email
            }
          }, status: :created
        else
          render json: {
            error: user.errors.full_messages.to_sentence
          }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
