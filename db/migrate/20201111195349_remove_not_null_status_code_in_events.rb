class RemoveNotNullStatusCodeInEvents < ActiveRecord::Migration[6.0]
  def change
    change_column_null :events, :status_code, true 
  end
end
