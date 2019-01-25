class UpdateProjectIdFieldToBigInt < ActiveRecord::Migration[5.2]
  def change
    change_column :estimates, :project_id, :bigint
  end
end
