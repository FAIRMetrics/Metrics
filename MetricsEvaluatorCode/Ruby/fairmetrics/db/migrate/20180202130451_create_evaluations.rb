class CreateEvaluations < ActiveRecord::Migration[5.1]
  def change
    create_table :evaluations do |t|
      t.string :collection
      t.string :resource
      t.string :body
      t.string :result
      t.string :executor
      t.string :title

      t.timestamps
    end
  end
end
