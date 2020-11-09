class AddUniquenessConstraint < ActiveRecord::Migration[6.0]
  def change
    add_index :bridges, :inbound_url, unique: true
  end
end
