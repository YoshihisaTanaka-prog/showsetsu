class CreateCharacters < ActiveRecord::Migration[6.1]
  def change
    create_table :characters do |t|
      t.string :name
      t.text :comment
      t.integer :user_id
      t.integer :title_id

      t.timestamps
    end
  end
end
