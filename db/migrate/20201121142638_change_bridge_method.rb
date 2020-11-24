class ChangeBridgeMethod < ActiveRecord::Migration[6.0]
  def change
    rename_column :bridges, :method, :http_method
  end
end
