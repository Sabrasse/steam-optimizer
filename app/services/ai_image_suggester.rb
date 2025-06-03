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
    You are a professional Steam store page designer and marketing expert.
  
    Analyze the attached image, which is the capsule for a Steam game. Your goal is to identify the most impactful visual improvements that would increase click-through rate (CTR), clarity, and appeal at a glance.
    
    
    Provide exactly 3 short bullet points. Each should include:
    - A specific issue or missed opportunity visible in the capsule
    - A brief suggestion for improvement (max 1 sentence)
    - The name of a successful Steam game that executes this aspect well (for comparison)
  
    Rules:
    - Each bullet point must be no more than 3 lines total.
    - Do not use markdown, emoji, or special characters.
    - Prioritize high-ROI visual changes (e.g. font clarity, focal point, contrast, readability, genre signaling).
  
    Focus on what a user would notice in a split second when scrolling the Steam store.
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
    
      Provide exactly 2 short bullet points:
      1. A visual check of the capsule image (quality, composition, readability)
      2. A required action, only if needed, to improve the image
    
      IMPORTANT: Do not include labels like "Visual Check" or "Required Action".
      Just write the 2 insights as plain bullet points, each starting with "- ".
      Do not use markdown, bold text, emojis, or checkmarks.
      Keep each bullet point concise, no more than 2 lines.
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