class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :sku, null: false
      t.string :category, null: false
      t.integer :stock_quantity, default: 0
      t.integer :low_stock_threshold, default: 5
      t.string :image_url
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :products, :sku, unique: true
    add_index :products, :category
    add_index :products, :active
  end
end
