class CopilotController < ApplicationController
  before_action :authenticate_user!

  def index
    @insights = current_user.health_insights.order(created_at: :desc)
    @memories = current_user.health_memories.order(source_date: :desc)
  end
end
