module HealthCopilot
  class RegenerateAppointmentBriefService
    def initialize(appointment_brief:)
      @appointment_brief = appointment_brief
      @user = appointment_brief.user
      @topic = appointment_brief.topic.to_s.strip
    end

    def call
      return @appointment_brief if @topic.blank?

      response = chat.ask(prompt)
      content = response.content.strip

      @appointment_brief.update!(
        title: "Appointment Prep: #{@topic.titleize}",
        content: content
      )

      @appointment_brief
    end

    private

    def chat
      RubyLLM.chat(
        model: "llama-3.1-8b-instant",
        provider: :openai,
        assume_model_exists: true
      ).with_tool(SearchHealthMemoriesTool.new(@user), choice: :auto)
    end

    def prompt
      <<~PROMPT
        You are an AI Health Copilot regenerating an existing appointment brief.

        Appointment topic:
        #{@topic}

        You have access to a tool called search_health_memories.
        Use the tool to search the user's health memories for information relevant to the appointment topic.

        Your job:
        1. Search for the latest memories related to the appointment topic.
        2. Replace the old brief with an updated version.
        3. Use only the tool results and the appointment topic.
        4. If the tool finds limited information, say that clearly.
        5. Do not include unrelated health issues.

        Rules:
        - Use the search_health_memories tool before writing the brief.
        - Focus only on the appointment topic.
        - Do not include unrelated medications, symptoms, tests, or conditions.
        - Do not diagnose.
        - Do not prescribe treatment.
        - Do not invent facts.
        - Do not claim a doctor said something unless the memories explicitly say that.
        - Do not describe numbers as normal, abnormal, healthy, or concerning unless the memory explicitly says that.
        - Avoid the phrase "treatment plan" unless the records explicitly mention a treatment plan.
        - Prefer safer phrases like next steps, evaluation, symptom history, what to monitor, or whether additional assessment is needed.
        - Do not suggest treatment options.
        - Questions should focus on understanding symptoms, next steps, and what information to bring.
        - Write directly to the user.

        Format the brief with these sections:

        Appointment Brief: #{@topic}

        1. Main Topics to Discuss
        2. Relevant Health History
        3. Medications, Tests, or Follow-ups Mentioned
        4. Questions You May Want to Ask
        5. Missing Information to Bring
      PROMPT
    end
  end
end
