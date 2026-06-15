class CopilotController < ApplicationController
  before_action :authenticate_user!

  def index
    @insights = current_user.health_insights.order(Arel.sql("CASE severity WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 ELSE 4 END"))
    @memories = current_user.health_memories.order(source_date: :desc)
    @doctor_questions = current_user.doctor_questions.where(status: "active").order(created_at: :desc)
  end
end
