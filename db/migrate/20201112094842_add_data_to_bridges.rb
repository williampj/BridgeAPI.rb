class AddDataToBridges < ActiveRecord::Migration[6.0]
  def change
    rename_column :bridges, :payload, :data
    rename_column :bridges, :name, :title
  end
end
