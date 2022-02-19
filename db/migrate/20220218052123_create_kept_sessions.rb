class CreateKeptSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :kept_sessions do |t|
      t.integer :st_id
      t.boolean :is_enabled, null: false, default: true
      
      t.integer :step, null: false, default: -1
      t.integer :title
      t.integer :chapter
      t.integer :story
      t.integer :character
      t.integer :synopsis

      t.integer :mode   , null: false, default: 1

      t.timestamps
    end
  end
end
