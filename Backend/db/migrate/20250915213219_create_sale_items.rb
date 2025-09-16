class CreateSaleItems < ActiveRecord::Migration[7.2]
  def change
    create_table :sale_items do |t|
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :line_total, precision: 10, scale: 2, null: false
      t.references :sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
    add_index :sale_items, [:sale_id, :product_id], unique: true
  end
end
