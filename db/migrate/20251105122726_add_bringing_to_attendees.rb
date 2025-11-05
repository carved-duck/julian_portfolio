class AddBringingToAttendees < ActiveRecord::Migration[7.1]
  def change
    add_column :attendees, :bringing, :string
  end
end
