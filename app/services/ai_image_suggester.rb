class AiImageSuggester
  MODEL = "gpt-4.1"

  def initialize
    Rails.logger.debug "Initializing AiImageSuggester with API key: #{ENV['OPENAI_API_KEY'].present?}"
    @client = OpenAI::Client.new
  end

  # Analyzes a Steam capsule image and provides suggestions for improvement
  def suggest_capsule_image_improvements(image_url)
    Rails.logger.debug "Attempting to analyze capsule image: #{image_url.present?}"
    return nil if image_url.nil? || image_url.strip.empty?

    prompt = <<~PROMPT
      Analyze this Steam game capsule image and provide specific suggestions for improvement. Consider:
      1. Visual impact and composition
      2. Branding and game identity
      3. Text readability (if any)
      4. Steam store page best practices
      5. Technical aspects (resolution, quality)

      Provide 3-5 specific, actionable suggestions for improvement.
    PROMPT

    begin
      Rails.logger.debug "Sending request to OpenAI API for image analysis"
      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: prompt.strip },
                { 
                  type: "image_url",
                  image_url: {
                    url: image_url
                  }
                }
              ]
            }
          ],
          max_tokens: 500
        }
      )
      Rails.logger.debug "Raw API Response for image analysis: #{response.inspect}"

      suggestions = response.dig("choices", 0, "message", "content")
      Rails.logger.debug "Extracted suggestions: #{suggestions.inspect}"
      suggestions&.strip
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error in suggest_capsule_image_improvements: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  # Validates if an image meets Steam's capsule image requirements
  def validate_capsule_image(image_url)
    Rails.logger.debug "Validating capsule image: #{image_url.present?}"
    return nil if image_url.nil? || image_url.strip.empty?

    prompt = <<~PROMPT
      Check if this Steam capsule image meets the following requirements:
      1. Resolution: 460x215 pixels (recommended)
      2. Format: JPG or PNG
      3. File size: Under 1MB
      4. No explicit content
      5. Clear and readable text (if any)
      6. Proper branding and game identity

      Provide a validation report with any issues found.
    PROMPT

    begin
      Rails.logger.debug "Sending request to OpenAI API for image validation"
      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: prompt.strip },
                { 
                  type: "image_url",
                  image_url: {
                    url: image_url
                  }
                }
              ]
            }
          ],
          max_tokens: 300
        }
      )
      Rails.logger.debug "Raw API Response for image validation: #{response.inspect}"

      validation = response.dig("choices", 0, "message", "content")
      Rails.logger.debug "Extracted validation: #{validation.inspect}"
      validation&.strip
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error in validate_capsule_image: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end
end 