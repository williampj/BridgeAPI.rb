class ImplementDatabase < ActiveRecord::Migration[6.0]
  def change
    create_table :bridges do |t|
      t.string :name, null: false
      t.string :inbound_url, null: false
      t.string :outbound_url, null: false
      t.string :method, null: false
      t.integer :retries, null: false
      t.integer :delay, null: false
      t.binary :payload, null: false

      t.timestamps
    end

    create_table :environment_variables do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.references :bridge, foreign_key: true, null: false

      t.timestamps
    end

    create_table :headers do |t|
      t.string :value, null: false
      t.string :key, null: false
      t.references :bridge, foreign_key: true, null: false

      t.timestamps
    end
    
    create_table :events do |t|
      t.boolean :completed, null: false
      t.binary :data, null: false
      t.string :inbound_url, null: false
      t.string :outbound_url, null: false
      t.integer :status_code, null: false
      t.datetime :completed_at
      t.references :bridge, foreign_key: true, null: false

      t.timestamps
    end
  end
end
