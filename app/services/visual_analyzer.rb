class VisualAnalyzer
  def initialize(game)
    @game = game
  end

  def analyze
    {
      score: calculate_score,
      issues: find_issues
    }
  end

  private

  def calculate_score
    issues = find_issues
    return 'F' if issues.size >= 3
    return 'D' if issues.size >= 2
    return 'C' if issues.size >= 1
    'A'
  end

  def find_issues
    issues = []
    
    # Check screenshots
    if @game.screenshots.blank?
      issues << "No screenshots uploaded"
    elsif @game.screenshots.size < 5
      issues << "Fewer than 5 screenshots (recommended: 5-10)"
    end
    
    # Check trailer
    if @game.movies.blank?
      issues << "No trailer uploaded"
    end
    
    issues
  end
end 