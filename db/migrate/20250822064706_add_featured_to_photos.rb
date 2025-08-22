class AddFeaturedToPhotos < ActiveRecord::Migration[7.1]
  def change
    add_column :photos, :featured, :boolean, default: false, null: false
  end
end
