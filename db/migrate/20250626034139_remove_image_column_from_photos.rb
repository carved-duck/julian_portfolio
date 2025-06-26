class RemoveImageColumnFromPhotos < ActiveRecord::Migration[7.1]
  def change
    remove_column :photos, :image, :string
  end
end
