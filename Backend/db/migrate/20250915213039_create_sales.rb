class CreateSales < ActiveRecord::Migration[7.2]
  def change
    create_table :sales do |t|
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.string :status, null: false, default: 'pending'
      t.string :payment_method, null: false
      t.text :notes
      t.references :user, null: false, foreign_key: true
      t.references :customer, null: true, foreign_key: true # Allow walk-in sales

      t.timestamps
    end
    add_index :sales, :status
    add_index :sales, :created_at
  end
end
