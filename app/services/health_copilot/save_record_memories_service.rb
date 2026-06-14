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
          next if bad_memory?(memory)

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

    private

    def bad_memory?(memory)
      title = memory["title"].to_s.strip.downcase
      value = memory["value"].to_s.strip.downcase

      title.blank? ||
        value.blank? ||
        value == "no" ||
        value == "none" ||
        value.include?("consult") ||
        value.include?("healthcare provider") ||
        value.include?("should be discussed")
    end
  end
end
