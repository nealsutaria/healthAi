# app/controllers/chat_controller.rb
require 'net/http'
require 'json'

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

    # Save user's message
    current_user.messages.create!(role: "user", content: user_message)

    # Fetch recent chat history (limit to 10 pairs)
    recent_messages = current_user.messages.order(created_at: :asc).last(20)

    # Build a flat conversation string
    history_text = recent_messages.map do |msg|
      role_label = msg.role == "user" ? "User" : "AI"
      "#{role_label}: #{msg.content}"
    end.join("\n")

    # Combine system prompt and history
    full_prompt = <<~PROMPT
      You are an AI assistant specialized in health-related questions.
      You can provide general information, explanations, and advice on health topics.
      I am not a medical health professional. Users should consult a doctor for medical advice, diagnosis, or treatment.
      Focus only on health-related queries. If a question is not health-related,
      politely decline to answer and remind the user of your purpose.

      Conversation so far:
      #{history_text}
    PROMPT

    api_key = Rails.application.credentials.gemini_api_key
    unless api_key
      render json: { error: "Gemini API key not configured." }, status: :internal_server_error
      return
    end

    api_url = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=#{api_key}")

    payload = {
      contents: [
        {
          role: "user",
          parts: [{ text: full_prompt }]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 600
      }
    }

    http = Net::HTTP.new(api_url.host, api_url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(api_url)
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    begin
      response = http.request(request)
      data = JSON.parse(response.body)

      ai_text = data.dig("candidates", 0, "content", "parts", 0, "text")

      if ai_text.present?
        current_user.messages.create!(role: "bot", content: ai_text)
        render json: { response: ai_text }
      else
        Rails.logger.warn "Gemini API returned no usable response: #{data.inspect}"
        render json: { response: "⚠️ I couldn’t generate a response. Try again later." }
      end

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




