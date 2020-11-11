class ChangeBinaryColumnsToJsonB < ActiveRecord::Migration[6.0]
  def change
    change_column :bridges, :payload, :jsonb, using: 'payload::text::jsonb', null: false
    change_column :events, :data, :jsonb, using: 'data::text::jsonb', null: false
  end
end
