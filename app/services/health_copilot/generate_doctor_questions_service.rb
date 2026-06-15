module HealthCopilot
  class GenerateDoctorQuestionsService
    def initialize(user)
      @user = user
    end

    def call
      memories = @user.health_memories.order(source_date: :desc)
      return if memories.empty?

      response = chat.ask(prompt_for(memories))
      data = parse_json(response.content)

      DoctorQuestion.transaction do
        @user.doctor_questions.destroy_all

        (data["questions"] || []).each do |question|
          @user.doctor_questions.create!(
            question: question,
            source: "memory_analysis",
            status: "active"
          )
        end
      end
    end

    private

    def chat
      RubyLLM.chat(
        model: "llama-3.1-8b-instant",
        provider: :openai,
        assume_model_exists: true
      )
    end

    def prompt_for(memories)
      memory_text = memories.map do |memory|
        "- #{memory.source_date} | #{memory.category} | #{memory.title}: #{memory.value}"
      end.join("\n")

      <<~PROMPT
        You are an AI Health Copilot.

        Create helpful questions the user may want to ask their doctor based on their saved health memories.

        Rules:
        - Questions must be grounded ONLY in the health memories provided.
        - Every question must reference at least one specific memory.
        - Prefer questions that combine multiple memories into one question.
        - Prioritize follow-ups, recurring symptoms, medication history, and test results.
        - Do not ask generic medical questions.
        - Do not ask about conditions not mentioned in the memories.
        - Do not diagnose.
        - Do not prescribe treatment.
        - Do not invent facts.
        - Return 3-5 questions maximum.

        Do not attribute anything to a doctor unless the memory explicitly says the doctor said it.
        Use neutral wording like "your records mention" instead of "your doctor said."
        Do not infer who recommended something.
        If a follow-up is mentioned, say "your records mention a follow-up" instead of "your doctor recommended a follow-up."

        Return ONLY valid JSON.
        Do not include markdown.

        Structure:
        {
          "questions": [
            "question text"
          ]
        }

        HEALTH MEMORIES:
        #{memory_text}
      PROMPT
    end

    def parse_json(raw_response)
      clean_response = raw_response.gsub(/```json|```/, "").strip
      JSON.parse(clean_response)
    rescue JSON::ParserError => e
      Rails.logger.error "DoctorQuestions JSON parse failed: #{e.message}"
      Rails.logger.error "Raw response: #{raw_response}"

      { "questions" => [] }
    end
  end
end
