class Analysis < ApplicationRecord
  belongs_to :game
  
  validates :status, presence: true
  validates :text_report, presence: true, if: :completed?
  validates :visual_report, presence: true, if: :completed?
  validates :tags_list, presence: true, if: :completed?
  validates :game_id, presence: true
  
  enum status: {
    processing: 0,
    completed: 1,
    failed: 2
  }
  
  scope :latest, -> { order(created_at: :desc).first }
  
  def processing?
    status == 'processing'
  end
  
  def completed?
    status == 'completed'
  end
  
  def failed?
    status == 'failed'
  end
  
  def mark_as_processing!
    update!(status: :processing)
  end
  
  def mark_as_completed!
    # Only convert to JSON if the data isn't already a string
    self.text_report = text_report.is_a?(String) ? text_report : text_report.to_json
    self.visual_report = visual_report.is_a?(String) ? visual_report : visual_report.to_json
    self.tags_list = tags_list.is_a?(String) ? tags_list : tags_list.to_json
    self.ai_suggestions = ai_suggestions.is_a?(String) ? ai_suggestions : ai_suggestions.to_json
    
    update!(status: :completed)
  rescue => e
    Rails.logger.error "Error marking analysis as completed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    mark_as_failed!
  end
  
  def mark_as_failed!
    update!(status: :failed)
  end

  # Add methods to safely parse JSON data
  def parsed_text_report
    return {} unless text_report.present?
    begin
      text_report.is_a?(String) ? JSON.parse(text_report) : text_report
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing text_report: #{e.message}"
      {}
    end
  end

  def parsed_visual_report
    return {} unless visual_report.present?
    begin
      visual_report.is_a?(String) ? JSON.parse(visual_report) : visual_report
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing visual_report: #{e.message}"
      {}
    end
  end

  def parsed_tags_list
    return [] unless tags_list.present?
    begin
      tags_list.is_a?(String) ? JSON.parse(tags_list) : tags_list
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing tags_list: #{e.message}"
      []
    end
  end

  def parsed_ai_suggestions
    return {} unless ai_suggestions.present?
    begin
      ai_suggestions.is_a?(String) ? JSON.parse(ai_suggestions) : ai_suggestions
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing ai_suggestions: #{e.message}"
      {}
    end
  end
end
