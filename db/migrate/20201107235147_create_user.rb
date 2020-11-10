class CreateUser < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :recovery_password_digest
      t.boolean :notifications, null: false, default: false

      t.timestamps null: false
    end
  end
end
