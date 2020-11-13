class AddTestToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :test, :boolean, default: false, null: false 
  end
end
