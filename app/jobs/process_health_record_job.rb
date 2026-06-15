class ProcessHealthRecordJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    record = Record.find_by(id: record_id)
    return unless record

    user = record.user

    HealthCopilot::SaveRecordMemoriesService.new(record).call
    HealthCopilot::GenerateInsightsService.new(user).call
    HealthCopilot::GenerateDoctorQuestionsService.new(user).call
  end
end
