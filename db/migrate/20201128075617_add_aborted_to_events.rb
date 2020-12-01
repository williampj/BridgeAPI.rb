class AddAbortedToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :aborted, :boolean, default: false, null: false
    change_column_null :events, :completed, false
  end
end
