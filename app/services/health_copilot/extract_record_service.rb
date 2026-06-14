module HealthCopilot
  class ExtractRecordService
    def initialize(record)
      @record = record
    end

    def call
      chat = RubyLLM.chat(
        model: "llama-3.1-8b-instant",
        provider: :openai,
        assume_model_exists: true
      )

      response = chat.ask(prompt)
      parse_json(response.content)
    end

    private

    def prompt
      <<~PROMPT
        You are an AI health record organizer.

        Extract only factual memories from this health record.
        Do not diagnose. Do not give medical advice.
        Do not invent information.
        Do not create memories for empty, missing, false, "No", or "None" values.
        Only create memories for meaningful health information.

        Return ONLY valid JSON.
        Do not wrap it in markdown.
        Do not include ```json.

        Use this exact structure:

        {
          "memories": [
            {
              "category": "visit_reason",
              "title": "actual short title from the record, never the words short label",
              "value": "specific factual memory from the record"
            }
          ]
        }

        Allowed categories:
        visit_reason
        medication
        test
        follow_up
        image_finding
        note

        HEALTH RECORD:
        Date: #{@record.date}
        Reason: #{@record.reason}
        Prescription: #{@record.prescription? ? "Yes" : "No"}
        Prescription Name: #{@record.prescription_name.presence || "None"}
        Xray Done: #{@record.xray_done? ? "Yes" : "No"}
        Test Done: #{@record.test_done? ? "Yes" : "No"}
        Test Type: #{@record.test_type.presence || "None"}
        Doctor Rating: #{@record.doctor_rating.presence || "None"}
        Comments: #{@record.comments.presence || "None"}
        Image Analysis: #{@record.analysis.presence || "None"}
      PROMPT
    end

    def parse_json(raw_response)
      clean_response = raw_response.gsub(/```json|```/, "").strip
      JSON.parse(clean_response)
    end
  end
end
