class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end
