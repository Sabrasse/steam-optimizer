class Game < ApplicationRecord
  has_many :analyses, dependent: :destroy
  
  validates :steam_app_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, on: :create
  
  private
  
  def generate_slug
    return if slug.present?
    
    # Generate base slug from name
    base_slug = name.parameterize
    
    # If slug exists, append a number
    counter = 1
    self.slug = base_slug
    while Game.exists?(slug: self.slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
