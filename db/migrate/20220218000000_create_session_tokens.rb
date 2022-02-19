class CreateSessionTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :session_tokens do |t|
      t.string  :session_id
      t.integer :user_id

      t.boolean :is_enabled, null: false, default: true

      t.string  :token
      t.integer :current_ks_id

      t.integer :design

      t.timestamps
    end
  end
end
