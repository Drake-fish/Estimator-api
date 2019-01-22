class AddAncestryToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :ancestry, :string
  end
end
