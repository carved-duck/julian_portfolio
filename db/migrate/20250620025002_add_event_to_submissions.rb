class AddEventToSubmissions < ActiveRecord::Migration[7.1]
  def change
    add_reference :submissions, :event, null: false, foreign_key: true
  end
end
