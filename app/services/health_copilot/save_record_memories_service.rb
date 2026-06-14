module HealthCopilot
  class SaveRecordMemoriesService
    def initialize(record)
      @record = record
      @user = record.user
    end

    def call
      extracted_data = ExtractRecordService.new(@record).call
      memories = extracted_data["memories"] || []

      HealthMemory.transaction do
        @record.health_memories.destroy_all

        memories.each do |memory|
          @record.health_memories.create!(
            user: @user,
            category: memory["category"],
            title: memory["title"],
            value: memory["value"],
            source_date: @record.date,
            confidence: 90
          )
        end
      end
    end
  end
end
