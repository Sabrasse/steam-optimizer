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
      You are a professional Steam store page designer. Analyze this game's capsule image and provide concise, actionable suggestions.

      Provide exactly 3 bullet points, each containing:
      - One specific improvement needed
      - One quick tip on how to implement it
      - One successful Steam game that does this well

      Keep each bullet point to 2-3 lines maximum.
      Do not use markdown formatting or special characters.
      Focus on the most impactful changes only.
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
          max_tokens: 300
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
      You are a Steam store page quality assurance specialist. Validate this game's capsule image.

      Provide exactly 3 bullet points:
      1. Technical check (resolution, format, size)
      2. Visual check (quality, composition, readability)
      3. Required actions (if any)

      Keep each bullet point to 2-3 lines maximum.
      Do not use markdown formatting or special characters.
      Focus on critical issues only.
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
          max_tokens: 200
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