class AddMetricsRefToCollections < ActiveRecord::Migration[5.1]
  def change
          add_reference  :metrics,  :collection,  foreign_key: true
  end
end
