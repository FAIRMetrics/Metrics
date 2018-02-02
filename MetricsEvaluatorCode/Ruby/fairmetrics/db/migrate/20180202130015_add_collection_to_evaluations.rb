class AddCollectionToEvaluations < ActiveRecord::Migration[5.1]
  def change
    add_column :evaluations, :collection, :integer
  end
end
