class AddOrcidToMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :metrics, :orcid, :string
  end
end
