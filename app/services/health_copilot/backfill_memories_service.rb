module HealthCopilot
  class BackfillMemoriesService
    def initialize(user)
      @user = user
    end

    def call
      @user.records.find_each do |record|
        SaveRecordMemoriesService.new(record).call
      end
    end
  end
end
