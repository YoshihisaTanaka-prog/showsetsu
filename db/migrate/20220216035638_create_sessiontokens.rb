class CreateSessiontokens < ActiveRecord::Migration[6.1]
  def change
    create_table :sessiontokens do |t|
      t.string :session_id
      t.string :token

      t.timestamps
    end
  end
end
