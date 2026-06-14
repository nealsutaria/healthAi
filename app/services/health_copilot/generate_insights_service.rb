module HealthCopilot
  class GenerateInsightsService
    def initialize(user)
      @user = user
    end

    def call
      memories = @user.health_memories.order(source_date: :desc)

      return if memories.empty?

      response = chat.ask(prompt_for(memories))
      data = parse_json(response.content)

      HealthInsight.transaction do
        @user.health_insights.destroy_all

        (data["insights"] || []).each do |insight|
          @user.health_insights.create!(
            record: memories.first.record,
            title: insight["title"],
            body: insight["body"],
            severity: insight["severity"],
            status: "active",
            source: "memory_analysis"
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

        Review these factual health memories and create helpful, safe insights.

        Write insights directly to the user.

        Use:
        "You"
        "Your records"

        Do not use:
        "The patient"
        "The individual"

        Analyze the memories and identify:

        1. Patterns
        2. Trends
        3. Follow-ups
        4. Important health events

        Do NOT give medical advice.
        Do NOT recommend treatments.
        Do NOT tell the user what to do.
        Only summarize what is present in the records.

        Rules:
        - Do not diagnose.
        - Do not prescribe treatment.
        - Do not claim certainty.
        - Do not give emergency instructions.
        - Use language like "consider discussing with your doctor."
        - Focus on patterns, follow-ups, repeated issues, and doctor-prep.

        Return ONLY valid JSON.
        Do not include markdown.

        Structure:
        {
          "insights": [
            {
              "title": "",
              "body": "",
              "severity": ""
            }
          ]
        }

        Severity must be one of:
        low
        medium
        high

        HEALTH MEMORIES:
        #{memory_text}
      PROMPT
    end

    def parse_json(raw_response)
      clean_response = raw_response.gsub(/```json|```/, "").strip
      JSON.parse(clean_response)
    end
  end
end
