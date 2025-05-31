class Analysis < ApplicationRecord
  belongs_to :game
  
  validates :status, presence: true
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
      raw = ai_suggestions.is_a?(String) ? JSON.parse(ai_suggestions) : ai_suggestions
      deep_symbolize_keys(raw)
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing ai_suggestions: #{e.message}"
      {}
    end
  end

  private

  def deep_symbolize_keys(obj)
    case obj
    when Hash
      obj.each_with_object({}) { |(k, v), h| h[k.to_sym] = deep_symbolize_keys(v) }
    when Array
      obj.map { |v| deep_symbolize_keys(v) }
    else
      obj
    end
  end
end
