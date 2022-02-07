class CreateStories < ActiveRecord::Migration[6.1]
  def change
    create_table :stories do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.integer :chapter_id
      t.integer :order
      t.integer :step_id

      t.timestamps
    end
  end
end
