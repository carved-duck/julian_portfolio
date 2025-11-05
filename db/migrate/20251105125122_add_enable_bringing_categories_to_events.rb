class AddEnableBringingCategoriesToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :enable_bringing_categories, :boolean, default: true
  end
end
