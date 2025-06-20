class CreateAttendees < ActiveRecord::Migration[7.1]
  def change
    create_table :attendees do |t|
      t.string :name
      t.string :instagram_handle
      t.text :message
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
