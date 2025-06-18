class CreateSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :submissions do |t|
      t.string :name
      t.string :instagram_handle
      t.text :message

      t.timestamps
    end
  end
end
