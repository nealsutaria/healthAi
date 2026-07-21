# app/controllers/chat_controller.rb

class ChatController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = current_user.messages.order(created_at: :asc)
  end

  def send_message
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

      render json: { response: ai_text }
    rescue => e
      Rails.logger.error "Gemini API error: #{e.message}"
      render json: { error: "AI communication failed: #{e.message}" }, status: :internal_server_error
    end
  end

  def clear
    current_user.messages.destroy_all
    redirect_to chat_path, notice: "Conversation cleared."
  end
end



