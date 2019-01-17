class CreateEstimates < ActiveRecord::Migration[5.2]
  def change
    create_table :estimates do |t|
      t.integer :optimistic, null: false, default: 0
      t.integer :realistic, null: false, default: 0
      t.integer :pessimistic, null: false, default: 0 
      t.text :note
      t.string :name, null: false
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
