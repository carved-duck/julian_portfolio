class AddFeaturedToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :featured, :boolean, default: false
  end
end
