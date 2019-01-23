class AddCompletedFieldToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :completed, :boolean, null: false, default: false
  end
end
