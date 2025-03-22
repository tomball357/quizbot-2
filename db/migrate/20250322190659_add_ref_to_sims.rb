class AddRefToSims < ActiveRecord::Migration[7.1]
  def change
    add_column :sims, :ref, :string
  end
end
