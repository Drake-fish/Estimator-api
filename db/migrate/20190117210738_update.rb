class Update < ActiveRecord::Migration[5.2]
  change_column_default(:estimates, :optimistic, 0)
  change_column_default(:estimates, :realistic, 0)
  change_column_default(:estimates, :pessimistic, 0)
  change_column_null(:projects, :name, false)
  change_column_null(:estimates, :optimistic, false)
  change_column_null(:estimates, :realistic, false)
  change_column_null(:estimates, :pessimistic, false)
  change_column_null(:estimates, :name, false)
end
