class AddDescriptionToMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :metrics, :description, :string
  end
end
