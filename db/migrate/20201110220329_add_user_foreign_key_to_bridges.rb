class AddUserForeignKeyToBridges < ActiveRecord::Migration[6.0]
  def change
    add_reference :bridges, :user, foreign_key: true, null: false 
  end
end
