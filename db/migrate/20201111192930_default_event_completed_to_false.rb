class DefaultEventCompletedToFalse < ActiveRecord::Migration[6.0]
  def change
    change_column_default :events, :completed, false
  end
end
