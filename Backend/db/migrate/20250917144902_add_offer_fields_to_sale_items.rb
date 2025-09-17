class AddOfferFieldsToSaleItems < ActiveRecord::Migration[7.2]
  def change
    add_column :sale_items, :discount_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :sale_items, :applied_offers, :text
  end
end
