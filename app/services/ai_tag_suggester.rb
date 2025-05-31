class AiTagSuggester
  MODEL = "gpt-3.5-turbo"

  def initialize
    @client = OpenAI::Client.new
  end

  def suggest_tags(game)
    prompt = <<~PROMPT
    You are a Steam store expert. Analyze the following game and improve its tag setup.
  
    Game Title: #{game.name}
    Short Description: #{game.short_description}
    Current Genres: #{game.genres&.map { |g| g['description'] }&.join(', ')}
    Current Categories: #{game.categories&.map { |c| c['description'] }&.join(', ')}
  
    Please provide:
  
    1. A list of 5–10 optimized Steam tags you recommend (new or improved).
    2. A score for the current tag setup (✔️ / ⚠️ / ❌).
    3. An evaluation of current tags: whether they should be kept (✔️), revised (⚠️), or removed (❌).
  
    Format your response like this:
  
    TAG_SCORE: [✔️ or ⚠️ or ❌]
  
    SUGGESTED_TAGS:
    ["tag1", "tag2", "tag3", ...]
  
    TAG_EVALUATION:
    - ✔️ "Action" – describes core gameplay accurately.
    - ⚠️ "RPG" – a bit too generic; consider "Action RPG".
    - ❌ "Gods" – not specific or relevant enough to help discoverability.
  
    Now analyze the game and provide your recommendations.
  PROMPT
  
  

    begin
      Rails.logger.debug "Sending request to OpenAI API for tag suggestions"
      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: [
            { role: "user", content: prompt.strip }
          ],
          temperature: 0.7
        }
      )

      content = response.dig("choices", 0, "message", "content")
      return nil unless content

      # Parse the response
      tag_score = content.match(/TAG_SCORE:\s*\[([^\]]+)\]/)&.[](1)&.strip
      suggested_tags = content.match(/SUGGESTED_TAGS:\s*\[(.*?)\]/m)&.[](1)&.split(',')&.map { |t| t.strip.delete_prefix('"').delete_suffix('"') }
      tag_evaluation = content.match(/TAG_EVALUATION:\s*((?:- .*)+)/m)&.[](1)&.strip

      {
        tag_score: tag_score,
        suggested_tags: suggested_tags,
        tag_evaluation: tag_evaluation
      }
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error in suggest_tags: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end
end 