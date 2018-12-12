class AddDeprecatedToMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :metrics, :deprecated, :boolean, default: false
  end
end
