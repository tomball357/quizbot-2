class CreateSims < ActiveRecord::Migration[7.1]
  def change
    create_table :sims do |t|
      t.string :topic
      t.text :description

      t.timestamps
    end
  end
end
