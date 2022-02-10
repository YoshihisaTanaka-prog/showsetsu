class AddSessionsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :title, :integer
    add_column :users, :chapter, :integer
    add_column :users, :story, :integer
    add_column :users, :synopsis, :integer
    add_column :users, :character, :integer
    add_column :users, :design, :integer
  end
end
