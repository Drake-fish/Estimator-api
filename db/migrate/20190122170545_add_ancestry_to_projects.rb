class AddAncestryToProjects < ActiveRecord::Migration[5.2]
  def change
    add_index :projects, :ancestry
  end
end
