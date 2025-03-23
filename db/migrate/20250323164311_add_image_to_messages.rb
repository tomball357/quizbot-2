class AddImageToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :image_url, :string
  end
end
