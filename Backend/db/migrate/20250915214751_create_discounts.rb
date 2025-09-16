class CreateDiscounts < ActiveRecord::Migration[7.2]
  def change
    create_table :discounts do |t|
      t.string :name, null: false
      t.text :description
      t.string :discount_type, null: false # 'percentage' or 'fixed_amount'
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.decimal :minimum_amount, precision: 10, scale: 2, default: 0
      t.boolean :active, default: true
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
    add_index :discounts, :active
    add_index :discounts, [:starts_at, :ends_at]
  end
end
