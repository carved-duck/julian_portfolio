class AddCapacityToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :capacity, :integer
    add_column :events, :target_capacity, :integer
  end
end
