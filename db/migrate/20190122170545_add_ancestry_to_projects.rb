class AddAncestryToProjects < ActiveRecord::Migration[5.2]
  def change
      add_column :projects, :ancestry, :string
    add_index :projects, :ancestry
  end
end
