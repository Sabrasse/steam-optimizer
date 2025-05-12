class VisualAnalyzer
  MIN_SCREENSHOTS = 5

  def initialize(game_data)
    @screens = game_data['screenshots'] || [] # array of screenshot info
    @videos = game_data['movies'] || [] # array of trailer info
  end

  def analyze
    issues = []
    count = @screens.size
    trailer_present = @videos.any?

    # Screenshot count analysis
    if count == 0
      issues << "No screenshots uploaded. At least #{MIN_SCREENSHOTS} screenshots are recommended."
    elsif count < MIN_SCREENSHOTS
      issues << "Only #{count} screenshots available (recommended minimum is #{MIN_SCREENSHOTS})."
    end

    # Trailer analysis
    unless trailer_present
      issues << "No trailer video present. A gameplay trailer is highly recommended."
    end

    # (Optional) Resolution check: ensure at least 1280x720.
    # For simplicity, we'll assume developers follow Steam's image guidelines.
    # A future improvement could use an image library to verify each screenshot's dimensions.

    # Determine letter grade for visuals
    score = if issues.empty?
      "A"
    elsif issues.size == 1
      # One issue (either screenshots slightly low or trailer missing) -> B
      "B"
    elsif issues.size == 2
      # Both a low screenshot count and no trailer -> C
      "C"
    else
      # Multiple serious issues (e.g., no visuals at all) -> F
      "F"
    end

    { score: score, issues: issues }
  end
end 