class AddAnonymousCustomerNameToSales < ActiveRecord::Migration[7.2]
  def change
    add_column :sales, :anonymous_customer_name, :string
  end
end
