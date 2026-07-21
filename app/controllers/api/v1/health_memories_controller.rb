# app/controllers/api/v1/health_memories_controller.rb

module Api
  module V1
    class HealthMemoriesController < BaseController
      def index
        memories = current_user.health_memories.order(source_date: :desc, created_at: :desc)

        render json: {
          health_memories: memories.map { |memory| health_memory_json(memory) }
        }
      end

      private

      def health_memory_json(memory)
        {
          id: memory.id,
          record_id: memory.record_id,
          category: memory.category,
          title: memory.title,
          value: memory.value,
          source_date: memory.source_date,
          confidence: memory.confidence,
          created_at: memory.created_at,
          updated_at: memory.updated_at
        }
      end
    end
  end
end
