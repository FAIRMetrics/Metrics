class CreateMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table :metrics do |t|
      t.string :name
      t.string :creator
      t.string :email
      t.string :principle
      t.string :smarturl
      t.integer :status

      t.timestamps
    end
  end
end
