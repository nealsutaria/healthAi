class RefreshHealthCopilotJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    HealthCopilot::GenerateInsightsService.new(user).call
    HealthCopilot::GenerateDoctorQuestionsService.new(user).call
  end
end
