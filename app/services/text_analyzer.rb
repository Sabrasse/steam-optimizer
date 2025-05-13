class TextAnalyzer
  RECOMMENDED_SHORT_LENGTH = 100..300 # Recommended range for short description length (in characters)
  RECOMMENDED_FIRST_PARA_LENGTH = 100..500 # Rough range for an engaging first paragraph length

  def initialize(game)
    @game = game
  end

  # Analyzes descriptions and returns a report hash with score and issues found.
  def analyze
    {
      score: calculate_score,
      issues: find_issues
    }
  end

  # Grades the tags (genres/categories) usage based on count, returning [score, feedback_message]
  def self.grade_tags(tags_list)
    return ['F', 'No tags found'] if tags_list.empty?
    
    # Count unique tags
    unique_tags = tags_list.uniq.size
    
    # Grade based on number of unique tags
    case unique_tags
    when 0..2
      ['F', 'Very few tags. Consider adding more relevant tags.']
    when 3..4
      ['D', 'Below average number of tags. More tags would help visibility.']
    when 5..6
      ['C', 'Average number of tags. Consider adding a few more.']
    when 7..8
      ['B', 'Good number of tags. Could add a few more for better coverage.']
    else
      ['A', 'Excellent tag coverage!']
    end
  end

  private

  def calculate_score
    issues = find_issues
    return 'F' if issues.size >= 5
    return 'D' if issues.size >= 4
    return 'C' if issues.size >= 3
    return 'B' if issues.size >= 2
    return 'A' if issues.size >= 1
    'A+'
  end

  def find_issues
    issues = []
    
    # Check short description
    if @game.short_description.blank?
      issues << "Missing short description"
    elsif @game.short_description.length < 50
      issues << "Short description is too brief (less than 50 characters)"
    elsif @game.short_description.length > 300
      issues << "Short description is too long (more than 300 characters)"
    end
    
    # Check about the game
    if @game.about_the_game.blank?
      issues << "Missing about the game section"
    elsif @game.about_the_game.length < 200
      issues << "About the game section is too brief (less than 200 characters)"
    end
    
    # Check for feature list
    unless @game.about_the_game&.include?("•") || @game.about_the_game&.include?("-")
      issues << "No bullet points or feature list found in the description"
    end
    
    issues
  end
end 