# app/controllers/api/v1/health_insights_controller.rb

module Api
  module V1
    class HealthInsightsController < BaseController
      def index
        insights = current_user.health_insights
          .where(status: "active")
          .order(Arel.sql("CASE severity WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 ELSE 4 END"))
          .order(created_at: :desc)

        render json: {
          health_insights: insights.map { |insight| health_insight_json(insight) }
        }
      end

      private

      def health_insight_json(insight)
        {
          id: insight.id,
          record_id: insight.record_id,
          title: insight.title,
          body: insight.body,
          severity: insight.severity,
          status: insight.status,
          source: insight.source,
          created_at: insight.created_at,
          updated_at: insight.updated_at
        }
      end
    end
  end
end
