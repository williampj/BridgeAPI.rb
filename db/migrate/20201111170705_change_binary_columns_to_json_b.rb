class ChangeBinaryColumnsToJsonB < ActiveRecord::Migration[6.0]
  def up
    change_column :bridges, :payload, :jsonb, using: 'payload::text::jsonb', null: false
    change_column :events, :data, :jsonb, using: 'data::text::jsonb', null: false
  end

  def down 
    change_column :bridges, :payload, :text
    change_column :events, :data, :text
  end
end
