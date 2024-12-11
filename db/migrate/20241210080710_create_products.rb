class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :price
      t.string :size
      t.datetime :scraped_at
      t.integer :category_id
      t.string :url

      t.timestamps
    end
    add_foreign_key :products, :categories, column: :category_id
    add_index :products, :category_id
  end
end
