class CreateJoinTableCollectionMetric < ActiveRecord::Migration[5.1]
  def change
    create_join_table :collections, :metrics do |t|
      # t.index [:collection_id, :metric_id]
      # t.index [:metric_id, :collection_id]
    end
  end
end
