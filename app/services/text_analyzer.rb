class TextAnalyzer
  RECOMMENDED_SHORT_LENGTH = 100..300 # Recommended range for short description length (in characters)
  RECOMMENDED_FIRST_PARA_LENGTH = 100..500 # Rough range for an engaging first paragraph length

  def initialize(game_data)
    @name = game_data['name'] || "(Unnamed Game)"
    @short_desc = (game_data['short_description'] || "").strip
    @long_desc = (game_data['about_the_game'] || "").strip
    # Strip HTML tags from long_desc if any (Steam descriptions may contain some HTML formatting)
    @long_desc = ActionView::Base.full_sanitizer.sanitize(@long_desc)
  end

  # Analyzes descriptions and returns a report hash with score and issues found.
  def analyze
    issues = []

    # Analyze short description
    short_length = @short_desc.length
    if @short_desc.empty?
      issues << "No short description provided."
    elsif short_length < RECOMMENDED_SHORT_LENGTH.min
      issues << "Short description is too brief (#{short_length} characters; consider ~120+ characters)."
    elsif short_length > RECOMMENDED_SHORT_LENGTH.max
      issues << "Short description is quite long (#{short_length} characters; consider trimming)."
    end

    # Check for a strong hook in short description (very basic check: exclamation or question mark)
    if !@short_desc.empty? && @short_desc =~ /(!|\?$)/
      # If it ends in an exclamation or question, assume it's trying to hook (just a simple heuristic)
    else
      # (Optional) We could use AI or keyword checks to detect excitement; for now, just note if missing
      # For simplicity, if the short desc is present but contains no punctuation indicating excitement
      issues << "Short description could be more of a hook to grab attention." unless @short_desc.empty?
    end

    # Analyze long description (About the Game)
    first_para = @long_desc.split(/\r?\n\r?\n/)[0] || @long_desc # take text until first blank line
    first_para_length = first_para.strip.length
    if first_para_length < RECOMMENDED_FIRST_PARA_LENGTH.min
      issues << "The first paragraph of the description might be too short. Consider expanding it."
    end

    # Check for bullet-point list of features in the long description
    if @long_desc.include?("•") || @long_desc.match?(/^\s*[\-\*]\s+/)
      # Contains bullet list characters (•, -, or *) at line starts
      # Good, it has a feature list
    else
      issues << "No bullet-point feature list detected in the description. Adding a concise feature list is recommended."
    end

    # Determine a letter grade for the description section:
    score = if issues.empty?
      "A"
    elsif issues.size <= 2
      "B"
    elsif issues.size <= 4
      "C"
    else
      "D"
    end

    { score: score, issues: issues }
  end

  # Grades the tags (genres/categories) usage based on count, returning [score, feedback_message]
  def self.grade_tags(tag_list)
    tag_count = tag_list.size
    score = case
    when tag_count == 0
      "F"
    when tag_count < 3
      "C" # too few tags
    when tag_count < 5
      "B"
    else
      "A"
    end

    feedback = if tag_count == 0
      "No tags/genres found. You should add relevant genre and category tags to help players find your game."
    elsif tag_count < 3
      "Only #{tag_count} tags listed. Consider adding more specific genres/categories."
    elsif tag_count < 5
      "Tags are okay, but a couple more could help. Make sure all major aspects of your game are tagged."
    else
      "Good variety of tags (#{tag_count}). The game is well-categorized for discovery."
    end

    [score, feedback]
  end
end 