class AddDeprecatedToEvaluations < ActiveRecord::Migration[5.1]
  def change
    add_column :evaluations, :deprecated, :boolean, default: false
  end
end
