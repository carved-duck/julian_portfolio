class RemoveCapacityFromEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :capacity, :integer
  end
end
