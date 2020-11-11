class RemoveDefaultAttribute < ActiveRecord::Migration[6.0]
  def change
    change_column_default :bridges, :payload, nil 
  end
end
