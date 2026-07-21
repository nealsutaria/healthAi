# app/services/health_chat/send_message_service.rb
require "net/http"
require "json"

module HealthChat
  class SendMessageService
    def initialize(user:, message:)
      @user = user
      @message = message.to_s.strip
    end

    def call
      raise ArgumentError, "Message cannot be empty." if @message.blank?

      @user.messages.create!(role: "user", content: @message)

      ai_text = generate_ai_response

      @user.messages.create!(role: "bot", content: ai_text)

      ai_text
    end

    private

    def generate_ai_response
      api_key = Rails.application.credentials.gemini_api_key
      raise "Gemini API key not configured." if api_key.blank?

      api_url = URI(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=#{api_key}"
      )

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

      response = http.request(request)
      data = JSON.parse(response.body)

      ai_text = data.dig("candidates", 0, "content", "parts", 0, "text")

      if ai_text.present?
        ai_text
      else
        Rails.logger.warn "Gemini API returned no usable response: #{data.inspect}"
        "⚠️ I couldn’t generate a response. Try again later."
      end
    end

    def full_prompt
      <<~PROMPT
        You are an AI assistant specialized in health-related questions.
        You can provide general information, explanations, and advice on health topics.
        You are not a medical health professional. Users should consult a doctor for medical advice, diagnosis, or treatment.

        Focus only on health-related queries. If a question is not health-related,
        politely decline to answer and remind the user of your purpose.

        Conversation so far:
        #{history_text}
      PROMPT
    end

    def history_text
      recent_messages = @user.messages.order(created_at: :asc).last(20)

      recent_messages.map do |msg|
        role_label = msg.role == "user" ? "User" : "AI"
        "#{role_label}: #{msg.content}"
      end.join("\n")
    end
  end
end
