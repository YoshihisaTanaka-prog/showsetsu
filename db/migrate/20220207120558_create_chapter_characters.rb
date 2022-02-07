class CreateChapterCharacters < ActiveRecord::Migration[6.1]
  def change
    create_table :chapter_characters do |t|
      t.references :chapter, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true
      t.integer :order

      t.timestamps
    end
  end
end
