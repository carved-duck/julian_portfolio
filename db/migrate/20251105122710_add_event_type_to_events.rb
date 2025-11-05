class AddEventTypeToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :event_type, :string, default: 'bbq'
    add_index :events, :event_type
  end
end
