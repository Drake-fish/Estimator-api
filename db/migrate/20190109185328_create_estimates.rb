class CreateEstimates < ActiveRecord::Migration[5.2]
  def change
    create_table :estimates do |t|
      t.integer :optimistic
      t.integer :realistic
      t.integer :pessimistic
      t.text :note
      t.string :name
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
