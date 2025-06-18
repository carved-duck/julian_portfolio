class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.string :github_url
      t.string :live_url
      t.string :featured_image
      t.string :tags

      t.timestamps
    end
  end
end
