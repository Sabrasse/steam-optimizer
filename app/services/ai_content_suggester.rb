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
    You are an expert in video game marketing and Steam store optimization. Analyze the following short description to assess its effectiveness at engaging potential players.

    Provide a quality score for each section using ✔️ / ⚠️ / ❌, and give short, actionable feedback for any ⚠️ or ❌.

    IMPORTANT FORMAT INSTRUCTIONS:
      - Section 1 (Length Check) must include:
        - The score symbol ✔️ / ⚠️ / ❌
        - The character count in this format: "Character count: 193."
        - A short explanation (1 line max) on whether it's too short, too long, or ideal.
        - The entire response should be on a single line, like this:  
          - ✔️ Character count: 193. The description is within the ideal range.
      - Sections 2–6 must follow this format:
      - ✔️ Your explanation here.  
      - ⚠️ Your explanation here.  
      - ❌ Your explanation here.  
      - Do not repeat the score before or after the bullet point.
      - Use only plain text, no markdown, bold, or indentation.
      - Keep all answers clean and uniform.

    At the end, rewrite the description to make it more compelling and conversion-focused (ideally between 120–300 characters).

    Respond in this exact format:

    ===
    Overall Summary:
    [1–2 line summary of strengths or key issue]

    1. Length Check (✔️ / ⚠️ / ❌)
      - [✔️ or ⚠️ or ❌] Character count: [number]. [brief explanation]

    2. Clarity (✔️ / ⚠️ / ❌)
    - [✔️ or ⚠️ or ❌] Your explanation here.

    3. Tone Match (✔️ / ⚠️ / ❌)
    - [✔️ or ⚠️ or ❌] Your explanation here.

    4. Unique Selling Point (USP) (✔️ / ⚠️ / ❌)
    - [✔️ or ⚠️ or ❌] Your explanation here.

    5. Generic Language Check (✔️ / ⚠️ / ❌)
    - [✔️ or ⚠️ or ❌] Your explanation here.

    6. Feature Dump Check (✔️ / ⚠️ / ❌)
    - [✔️ or ⚠️ or ❌] Your explanation here.

    7. Suggestions for Improvement
    - Tip 1: [brief actionable tip]
    - Tip 2: [optional]

    8. Improved Short Description
    - "[rewritten description]" (Character count in parentheses)

    Now analyze this short description:
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

      content = response.dig("choices", 0, "message", "content")
      Rails.logger.debug "Extracted content: #{content.inspect}"
      return nil unless content

      # Parse the response into a structured hash
      sections = content.split(/\d+\.\s+/).reject(&:empty?)
      analysis = {}

      sections.each do |section|
        if section.start_with?("Length Check")
          match_status = section.match(/(✔️|⚠️|❌)/)
          match_chars = section.match(/Character(?:s| count)[: ]+(\d+)/i)
          char_count = match_chars ? match_chars[1] : current_short_desc&.length
          analysis[:length_check] = {
            status: match_status ? match_status[1] : nil,
            details: char_count
          }
        elsif section.start_with?("Clarity")
          match_status = section.match(/\((.*?)\)/)
          analysis[:clarity] = {
            status: match_status ? match_status[1] : nil,
            details: section.split("\n")[1..-1].join("\n").strip
          }
        elsif section.start_with?("Tone Match")
          match_status = section.match(/\((.*?)\)/)
          analysis[:tone_match] = {
            status: match_status ? match_status[1] : nil,
            details: section.split("\n")[1..-1].join("\n").strip
          }
        elsif section.start_with?("Unique Selling Point")
          match_status = section.match(/\((.*?)\)/)
          analysis[:usp] = {
            status: match_status ? match_status[1] : nil,
            details: section.split("\n")[1..-1].join("\n").strip
          }
        elsif section.start_with?("Generic Language Check")
          match_status = section.match(/\((.*?)\)/)
          analysis[:generic_language] = {
            status: match_status ? match_status[1] : nil,
            details: section.split("\n")[1..-1].join("\n").strip
          }
        elsif section.start_with?("Feature Dump Check")
          match_status = section.match(/\((.*?)\)/)
          analysis[:feature_dump] = {
            status: match_status ? match_status[1] : nil,
            details: section.split("\n")[1..-1].join("\n").strip
          }
        elsif section.start_with?("Suggestions for Improvement")
          analysis[:suggestions] = section.split("\n")[1..-1].join("\n").strip
        elsif section.start_with?("Improved Short Description")
          analysis[:improved_description] = section.split("\n")[1..-1].join("\n").strip
        end
      end

      analysis
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error in improve_short_description: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end
end 