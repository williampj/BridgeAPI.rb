class AddActiveToBridges < ActiveRecord::Migration[6.0]
  def change
    add_column :bridges, :active, :boolean, default: :true
  end
end
