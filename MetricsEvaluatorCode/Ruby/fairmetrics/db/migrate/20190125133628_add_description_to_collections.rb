class AddDescriptionToCollections < ActiveRecord::Migration[5.1]
  def change
    add_column :collections, :description, :string
  end
end
