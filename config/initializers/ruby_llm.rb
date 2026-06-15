RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.groq_api_key || ENV["GROQ_API_KEY"]
  config.openai_api_base = "https://api.groq.com/openai/v1"
end
