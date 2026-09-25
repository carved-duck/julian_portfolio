class AddHighlightsToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :highlights, :text # "What I built" bullets, one per line
  end
end
