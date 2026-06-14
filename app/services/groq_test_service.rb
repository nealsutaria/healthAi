class GroqTestService
  def self.call
    chat = RubyLLM.chat(
      model: "llama-3.1-8b-instant",
      provider: :openai,
      assume_model_exists: true
    )

    response = chat.ask("Respond with exactly: Groq is working")

    response.content
  end
end
