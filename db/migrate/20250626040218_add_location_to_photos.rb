class AddLocationToPhotos < ActiveRecord::Migration[7.1]
  def change
    add_column :photos, :location, :string
  end
end
