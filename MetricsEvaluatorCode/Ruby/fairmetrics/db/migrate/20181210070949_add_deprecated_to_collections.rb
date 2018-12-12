class AddDeprecatedToCollections < ActiveRecord::Migration[5.1]
  def change
    add_column :collections, :deprecated, :boolean, default: false
  end
end
