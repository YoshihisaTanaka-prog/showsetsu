class CreateSessionTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :session_tokens do |t|
      t.string  :session_id
      t.integer :user_id

      t.string  :token
      t.integer :current_ks_id

      t.timestamps
    end
  end
end
