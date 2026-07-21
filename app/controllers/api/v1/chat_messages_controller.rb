# app/controllers/api/v1/chat_messages_controller.rb

module Api
  module V1
    class ChatMessagesController < BaseController
      def index
        messages = current_user.messages.order(created_at: :asc)

        render json: {
          messages: messages.map { |message| message_json(message) }
        }
      end

      def create
        user_message = params[:message].to_s.strip

        if user_message.blank?
          render json: { error: "Message cannot be empty." }, status: :unprocessable_entity
          return
        end

        begin
          ai_text = HealthChat::SendMessageService.new(
            user: current_user,
            message: user_message
          ).call

          render json: {
            response: ai_text,
            messages: current_user.messages.order(created_at: :asc).map { |message| message_json(message) }
          }
        rescue => e
          Rails.logger.error "Chat API error: #{e.message}"
          render json: { error: "AI communication failed: #{e.message}" }, status: :internal_server_error
        end
      end

      def destroy_all
        current_user.messages.destroy_all

        render json: {
          message: "Conversation cleared."
        }
      end

      private

      def message_json(message)
        {
          id: message.id,
          role: message.role,
          content: message.content,
          created_at: message.created_at,
          updated_at: message.updated_at
        }
      end
    end
  end
end
