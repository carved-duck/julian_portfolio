class AddStartedOnToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :started_on, :date
  end
end
