class RemoveCollectionIdFromMetrics < ActiveRecord::Migration[5.1]
  def change
    remove_column :metrics, :collection_id, :integer
  end
end
