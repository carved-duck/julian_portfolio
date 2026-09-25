# frame: how a project's image is shown on its card (a browser window, an iPhone, or a terminal).
# section: where it sits on the Projects page (current work, earlier work, or bootcamp work).
class AddFrameAndSectionToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :frame, :string, null: false, default: "browser"
    add_column :projects, :section, :string, null: false, default: "work"
  end
end
