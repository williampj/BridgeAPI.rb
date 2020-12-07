class AddSlugToBridge < ActiveRecord::Migration[6.0]
  def change
    add_column :bridges, :slug, :string, null: false 
  end
end
