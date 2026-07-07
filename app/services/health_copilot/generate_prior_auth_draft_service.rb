module HealthCopilot
  class GeneratePriorAuthDraftService
    def initialize(prior_auth_draft:)
      @prior_auth_draft = prior_auth_draft
    end

    def call
      response = chat.ask(prompt)
      content = response.content.strip

      @prior_auth_draft.update!(
        content: content,
        status: "draft"
      )

      @prior_auth_draft
    end

    private

    def chat
      RubyLLM.chat(
        model: "openai/gpt-oss-120b",
        provider: :openai,
        assume_model_exists: true
      )
    end

    def prompt
      <<~PROMPT
        You are an AI prior authorization preparation assistant for a clinic.

        Your job is to help clinic staff prepare a prior authorization packet.
        You are not submitting anything to insurance.
        You are not making a medical decision.
        You are organizing the provided clinical context into a professional prior authorization preparation draft.
        Do not suggest possible diagnoses unless explicitly provided.
        Do not say “medically necessary”; say “documentation may support the request” or “clinical rationale based on provided notes.”

        Use only the information provided below.
        Do not invent facts.
        Do not claim a service is medically necessary unless the provided notes support that wording.
        If important information is missing, clearly list it under Missing Information.
        Write in a professional clinic-facing tone.

        PATIENT NAME:
        #{@prior_auth_draft.patient_name}

        CONDITION / DIAGNOSIS / CONCERN:
        #{@prior_auth_draft.condition}

        REQUESTED SERVICE:
        #{@prior_auth_draft.requested_service}

        INSURANCE PAYER:
        #{@prior_auth_draft.insurance_payer}

        PRIOR TREATMENTS TRIED:
        #{@prior_auth_draft.prior_treatments.presence || "Not provided"}

        CLINICAL NOTES:
        #{@prior_auth_draft.clinical_notes.presence || "Not provided"}

        TESTS OR IMAGING:
        #{@prior_auth_draft.tests_or_imaging.presence || "Not provided"}

        Create a prior authorization preparation packet with these sections:

        Prior Authorization Prep Packet

        1. Case Summary
        2. Requested Service
        3. Clinical Rationale Based on Provided Notes
        4. Prior Treatments Tried
        5. Supporting Documentation Available
        6. Missing Information / Documentation Gaps
        7. Draft Letter to Insurance
        8. Staff Checklist Before Submission

        Important rules for the Draft Letter:
        - Address it to the insurance payer.
        - Include the requested service.
        - Reference only the provided patient history.
        - Keep it professional.
        - Do not fabricate diagnosis codes, CPT codes, dates, or provider names.
        - Use placeholders where information is missing.
      PROMPT
    end
  end
end
