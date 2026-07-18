require "net/http"
require "json"
require "open-uri"
require "base64"
require "mini_magick"

module HealthCopilot
  class AnalyzeRecordImageService
    def initialize(record)
      @record = record
    end

    def call
      return { success: false, error: "No image attached to analyze." } unless @record.image.attached?

      downloaded_file = URI.open(@record.image.url)

      image = MiniMagick::Image.read(downloaded_file)
      image.resize "800x800>"

      base64_image = Base64.strict_encode64(image.to_blob)

      api_key = Rails.application.credentials.gemini_api_key
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=#{api_key}")

      body = {
        contents: [
          {
            parts: [
              { text: "Please analyze and explain this medical image clearly." },
              {
                inline_data: {
                  mime_type: "image/jpeg",
                  data: base64_image
                }
              }
            ]
          }
        ]
      }

      headers = { "Content-Type" => "application/json" }

      response = Net::HTTP.post(uri, body.to_json, headers)
      json = JSON.parse(response.body)

      result = json.dig("candidates", 0, "content", "parts", 0, "text")

      if result.present?
        @record.update!(analysis: result)
        { success: true, analysis: result }
      else
        Rails.logger.error "Gemini error: #{json.inspect}"
        { success: false, error: "Gemini could not analyze the image." }
      end
    rescue => e
      Rails.logger.error "Gemini image analysis failed: #{e.message}"
      { success: false, error: "Something went wrong while analyzing the image." }
    end
  end
end
