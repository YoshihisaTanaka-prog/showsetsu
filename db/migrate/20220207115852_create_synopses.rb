class CreateSynopses < ActiveRecord::Migration[6.1]
  def change
    create_table :synopses do |t|
      t.text :comment
      t.integer :user_id
      t.integer :title_id

      t.timestamps
    end
  end
end
