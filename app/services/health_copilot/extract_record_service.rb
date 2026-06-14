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

        A memory is a factual detail from the record that may be useful later.
        A memory is NOT advice.

        A memory must be a factual observation from the record.

        Good memories:
        - Diagnoses
        - Symptoms
        - Test results
        - Medications
        - Follow-up events
        - Appointment details
        - Image findings

        Bad memories:
        - Advice
        - Recommendations
        - Warnings
        - Medical disclaimers
        - Suggested treatments
        - Questions

        Never store:
        - "consult your doctor"
        - "talk to a healthcare provider"
        - "follow provider recommendations"
        - legal disclaimers
        - safety disclaimers

        Only store facts that actually happened or were observed.
        Never copy placeholder text from the JSON example.

        Return ONLY valid JSON.
        Do not wrap it in markdown.
        Do not include ```json.

        Use this exact structure:

        {
          "memories": [
            {
              "category": "visit_reason",
              "title": "example_title",
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
