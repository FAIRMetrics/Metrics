class AddTestOfMetricToMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :metrics, :test_of_metric, :string
  end
end
