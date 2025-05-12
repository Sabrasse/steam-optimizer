class AiContentSuggester
  MODEL = "gpt-3.5-turbo"

  def initialize
    Rails.logger.debug "Raw API Key value: #{ENV['OPENAI_API_KEY']}"
    @client = OpenAI::Client.new # uses the configured access token from initializer
    Rails.logger.debug "AiContentSuggester initialized with API key: #{ENV['OPENAI_API_KEY'].present?}"
  end

  # Generates a more compelling short description (couple of sentences) for the game.
  def improve_short_description(current_short_desc)
    Rails.logger.debug "Attempting to improve short description: #{current_short_desc.present?}"
    return nil if current_short_desc.nil? || current_short_desc.strip.empty?

    prompt = <<~PROMPT
      The following is a short description for a Steam game. Rewrite it to be more compelling and engaging, while keeping it concise (around 120-300 characters):
      "#{current_short_desc.strip}"
    PROMPT

    begin
      Rails.logger.debug "Sending request to OpenAI API for short description"
      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: [
            { role: "user", content: prompt.strip }
          ],
          temperature: 0.7
        }
      )
      Rails.logger.debug "Raw API Response for short description: #{response.inspect}"

      new_desc = response.dig("choices", 0, "message", "content")
      Rails.logger.debug "Extracted new description: #{new_desc.inspect}"
      new_desc&.strip
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error in improve_short_description: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  # Suggests an improved first paragraph for the long description.
  def improve_first_paragraph(full_description)
    Rails.logger.debug "Attempting to improve first paragraph: #{full_description.present?}"
    return nil if full_description.nil? || full_description.strip.empty?

    # Extract current first paragraph from the full description
    current_intro = full_description.split(/\r?\n\r?\n/)[0] || full_description
    Rails.logger.debug "Extracted current intro: #{current_intro.present?}"

    prompt = <<~PROMPT
      Here is the first part of a Steam game's description:
      """
      #{current_intro.strip}
      """
      Rewrite this introduction to grab the reader's attention more effectively (keep it concise, around 100-500 characters).
    PROMPT

    begin
      Rails.logger.debug "Sending request to OpenAI API for first paragraph"
      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: [
            { role: "user", content: prompt.strip }
          ],
          temperature: 0.7
        }
      )
      Rails.logger.debug "Raw API Response for first paragraph: #{response.inspect}"

      new_intro = response.dig("choices", 0, "message", "content")
      Rails.logger.debug "Extracted new intro: #{new_intro.inspect}"
      new_intro&.strip
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error in improve_first_paragraph: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  # Generates a bullet-point list of 5 key features of the game, based on its long description
  def suggest_feature_list(full_description)
    Rails.logger.debug "Attempting to suggest feature list: #{full_description.present?}"
    return nil if full_description.nil? || full_description.strip.empty?

    prompt = <<~PROMPT
      Based on the following game description, list 5 key features or selling points of the game in a concise, bullet-point format:
      """
      #{full_description.strip}
      """
    PROMPT

    begin
      Rails.logger.debug "Sending request to OpenAI API for feature list"
      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: [
            { role: "user", content: prompt.strip }
          ],
          temperature: 0.7
        }
      )
      Rails.logger.debug "Raw API Response for feature list: #{response.inspect}"

      features_text = response.dig("choices", 0, "message", "content")
      Rails.logger.debug "Extracted features text: #{features_text.inspect}"
      return nil unless features_text

      # Post-process the response to format as an array of feature lines (remove any numbering or bullets)
      features = features_text.strip.split("\n").map do |line|
        line.gsub(/^\-|\d+\.\s*/, '').strip # remove leading "-" or "1. " etc.
      end

      # Remove any blank lines and limit to 5
      final_features = features.select { |f| !f.empty? }[0...5]
      Rails.logger.debug "Final processed features: #{final_features.inspect}"
      final_features
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error in suggest_feature_list: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end
end 