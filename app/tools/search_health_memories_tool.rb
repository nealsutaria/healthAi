class SearchHealthMemoriesTool < RubyLLM::Tool
  desc "Searches the current user's saved health memories for a specific appointment topic or health concern."

  param :query, desc: "The health topic to search for, such as shoulder pain, headaches, iron deficiency, blood pressure, or medication name."
  param :limit, type: :integer, desc: "Maximum number of memories to return.", required: false

  def initialize(user)
    @user = user
  end

  def execute(query:, limit: 10)
    return "No user available." unless @user
    return "No search query provided." if query.to_s.strip.blank?

    query_words = query.to_s.downcase.split.reject { |word| word.length < 3 }

    memories = @user.health_memories
      .order(source_date: :desc)
      .select do |memory|
        searchable_text = [
          memory.category,
          memory.title,
          memory.value,
          memory.source_date
        ].join(" ").downcase

        query_words.any? { |word| searchable_text.include?(word) }
      end
      .first(limit.to_i.clamp(1, 20))

    if memories.empty?
      return "No directly relevant health memories found for: #{query}"
    end

    memories.map do |memory|
      "- #{memory.source_date} | #{memory.category} | #{memory.title}: #{memory.value}"
    end.join("\n")
  end
end
