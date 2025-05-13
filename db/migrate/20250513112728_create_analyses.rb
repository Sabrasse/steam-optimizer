class CreateAnalyses < ActiveRecord::Migration[7.1]
  def change
    create_table :analyses do |t|
      t.references :game, null: false, foreign_key: true
      t.jsonb :text_report, default: {}
      t.jsonb :visual_report, default: {}
      t.jsonb :tags_list, default: {}
      t.jsonb :ai_suggestions, default: {}
      t.text :image_suggestions
      t.text :image_validation
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :analyses, [:game_id, :created_at]
  end
end
