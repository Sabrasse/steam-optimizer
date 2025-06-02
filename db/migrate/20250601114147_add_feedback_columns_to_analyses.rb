class AddFeedbackColumnsToAnalyses < ActiveRecord::Migration[7.1]
  def change
    add_column :analyses, :user_rating_tags, :string
    add_column :analyses, :user_rating_image, :string
    add_column :analyses, :user_rating_description, :string
    add_column :analyses, :user_feedback_tags, :text
    add_column :analyses, :user_feedback_image, :text
    add_column :analyses, :user_feedback_description, :text
  end
end
