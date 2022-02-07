class CreateSteps < ActiveRecord::Migration[6.1]
  def change
    create_table :steps do |t|
      t.string :name
      t.integer :user_id
      t.integer :order

      t.timestamps
    end
  end
end
