class UpdatingIdsToBigInt < ActiveRecord::Migration[5.2]
  def change
    change_column :estimates, :id, :bigint
    change_column :projects, :id, :bigint
  end
end
