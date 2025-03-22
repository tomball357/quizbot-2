class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.integer :sim_id
      t.text :body
      t.string :role

      t.timestamps
    end
  end
end
