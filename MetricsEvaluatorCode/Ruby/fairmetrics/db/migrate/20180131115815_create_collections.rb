class CreateCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :collections do |t|
      t.string :name
      t.string :contact
      t.string :organization

      t.timestamps
    end
  end
end
