class RenameSubmissionsToAttendees < ActiveRecord::Migration[7.1]
  def change
    rename_table :submissions, :attendees
  end
end
