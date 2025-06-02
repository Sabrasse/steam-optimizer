class Analysis < ApplicationRecord
  belongs_to :game
  
  validates :tags_list, presence: true
  validates :game_id, presence: true
  
  # Feedback validations
  validates :user_rating_tags, inclusion: { in: %w[thumbs_up thumbs_down], allow_nil: true }
  validates :user_rating_image, inclusion: { in: %w[thumbs_up thumbs_down], allow_nil: true }
  validates :user_rating_description, inclusion: { in: %w[thumbs_up thumbs_down], allow_nil: true }
  
  scope :latest, -> { order(created_at: :desc).first }
  
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
