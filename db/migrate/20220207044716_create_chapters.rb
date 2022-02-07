class CreateChapters < ActiveRecord::Migration[6.1]
  def change
    create_table :chapters do |t|
      t.string :title
      t.integer :user_id
      t.integer :title_id
      t.integer :order

      t.timestamps
    end
  end
end
