class AiImageSuggester
  MODEL = "gpt-4.1"

  def initialize
    Rails.logger.debug "Initializing AiImageSuggester with API key: #{ENV['OPENAI_API_KEY'].present?}"
    @client = OpenAI::Client.new
  end

  def suggest_capsule_image_improvements(image_url, game_name = nil, genre = nil)
    Rails.logger.debug "Attempting to analyze capsule image: #{image_url.present?}"
    return nil if image_url.blank?

    prompt = build_capsule_prompt(game_name, genre)

    begin
      Rails.logger.debug "Sending request to OpenAI API for capsule image analysis"

      response = @client.chat(
        parameters: {
          model: MODEL,
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: prompt.strip },
                { type: "image_url", image_url: { url: image_url } }
              ]
            }
          ],
          max_tokens: 700
        }
      )

      Rails.logger.debug "Raw API Response: #{response.inspect}"

      suggestions = response.dig("choices", 0, "message", "content")
      if suggestions.blank? || !suggestions.include?("4. Hook / Genre Visibility")
        Rails.logger.warn("⚠️ Capsule image response missing Section 4 or empty")
      end

      suggestions&.strip
    rescue => e
      Rails.logger.error "OpenAI API Error in suggest_capsule_image_improvements: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  private

  def build_capsule_prompt(game_name, genre)
    <<~PROMPT
      You are a Steam marketing expert. Your job is to evaluate a game's capsule image to help an indie dev increase discoverability and conversions. Be clear, constructive, and specific — speak like you're advising a solo dev preparing for release.

      ❌ Do NOT comment on file size, resolution, or technical specs unless the image is visibly broken.  
      ✅ Focus on layout, readability, focal clarity, and whether the image communicates *genre* and *hook* effectively at small sizes (especially 120×45px).

      Use this structure exactly:

      ===
      **Capsule Image Evaluation#{game_name ? " for \"#{game_name}\"" : ""}**

      1. Art Quality (✔️ / ⚠️ / ❌)  
      - Is the art polished, consistent with the in-game style, and visually appealing?  
      - [Brief but specific critique]  
      - Tip (if ⚠️ or ❌): [Short, actionable improvement]

      2. Readability (✔️ / ⚠️ / ❌)  
      - Can the title be clearly read at small sizes? Are contrast, font, and subtitle/tagline effective?  
      - [Name any readability blockers directly — font, overlay, background clutter, etc.]  
      - Tip (if ⚠️ or ❌): [Concrete readability fix]

      3. Focus / Visual Hierarchy (✔️ / ⚠️ / ❌)  
      - Is attention clearly guided to the key elements (title, character, mechanic)?  
      - [Identify competing elements if present — e.g., “rock and character overlap title”]  
      - Tip (if ⚠️ or ❌): [Improvement to structure, spacing, or anchoring]

      4. Hook / Genre Visibility (✔️ / ⚠️ / ❌)  
      - Does the image suggest the game's genre, tone, or core mechanic *at a glance*?  
      - [This section is mandatory — if unclear, explain why AND what’s missing (e.g. no action, no genre-defining iconography). Suggest how it could visually hint at gameplay.]  
      - Tip (if ⚠️ or ❌): [What visual cue could clarify it?]

      ===
      **Overall Summary**  
      Summarize biggest strength(s) and the most important improvement to make.

      **Comparative Insight**  
      Mention at least one game in the same genre (e.g. *Teslagrad*, *FEZ*) that uses capsule space effectively. If no perfect match, suggest a visually similar reference and why it works.

      Now evaluate the capsule image#{game_name ? " for \"#{game_name}\"" : ""}.#{genre ? " It belongs to the #{genre} genre — keep that in mind." : ""}
    PROMPT
  end
end
