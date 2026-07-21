# app/controllers/api/v1/google_sessions_controller.rb
require "net/http"
require "json"

module Api
  module V1
    class GoogleSessionsController < ActionController::API
      def create
        id_token = params[:id_token].to_s.strip

        if id_token.blank?
          render json: { error: "Google ID token is required." }, status: :unprocessable_entity
          return
        end

        google_user = verify_google_id_token(id_token)

        unless google_user
          render json: { error: "Invalid Google token." }, status: :unauthorized
          return
        end

        email = google_user["email"].to_s.downcase
        google_uid = google_user["sub"].to_s

        if email.blank?
          render json: { error: "Google account email missing." }, status: :unprocessable_entity
          return
        end

        user = User.find_or_initialize_by(email: email)

        if user.new_record?
          user.password = Devise.friendly_token[0, 32]
        end

        if user.respond_to?(:provider=)
          user.provider = "google_oauth2"
        end

        if user.respond_to?(:uid=)
          user.uid = google_uid
        end

        user.save!
        user.ensure_api_token!

        render json: {
          token: user.api_token,
          user: {
            id: user.id,
            email: user.email
          }
        }
      rescue => e
        Rails.logger.error "Google login API error: #{e.message}"
        render json: { error: "Google login failed." }, status: :internal_server_error
      end

      private

      def verify_google_id_token(id_token)
        uri = URI("https://oauth2.googleapis.com/tokeninfo?id_token=#{id_token}")

        response = Net::HTTP.get_response(uri)

        return nil unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)

        expected_client_id = google_ios_client_id

        if expected_client_id.present? && data["aud"] != expected_client_id
          Rails.logger.warn "Google token audience mismatch. Expected #{expected_client_id}, got #{data["aud"]}"
          return nil
        end

        return nil unless data["email_verified"] == "true" || data["email_verified"] == true

        data
      end

      def google_ios_client_id
        Rails.application.credentials.dig(:google, :ios_client_id) ||
          ENV["GOOGLE_IOS_CLIENT_ID"]
      end
    end
  end
end
