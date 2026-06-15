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

        Your job is NOT to summarize records.
        Your job is to find meaningful patterns across the user's health memories.

        Only create an insight if it identifies one of:
        - a repeated symptom across multiple records
        - a follow-up item mentioned in a record
        - a medication connected to a symptom
        - a test result connected to a condition or follow-up
        - a change over time
        - an important doctor-prep observation

        Do not create generic summaries.
        Do not restate a single memory unless it is important for follow-up.
        Do not say obvious things like "you take this medication" unless connected to a symptom, test, or pattern.
        Do not diagnose.
        Do not prescribe treatment.
        Do not invent facts.
        Do not attribute anything to a doctor unless the memory explicitly says the doctor said it.
        Use neutral wording like "your records mention" instead of "your doctor said."
        Do not infer who recommended something.
        If a follow-up is mentioned, say "your records mention a follow-up" instead of "your doctor recommended a follow-up."

        Write directly to the user using "you" and "your records."

        If there are no meaningful patterns, return:
        {
          "insights": []
        }

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
