class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :steam_app_id, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.text :short_description
      t.text :about_the_game
      t.string :capsule_image_url
      t.jsonb :genres, default: {}
      t.jsonb :categories, default: {}
      t.jsonb :screenshots, default: {}
      t.jsonb :movies, default: {}

      t.timestamps
    end

    add_index :games, :steam_app_id, unique: true
    add_index :games, :slug, unique: true
  end
end
