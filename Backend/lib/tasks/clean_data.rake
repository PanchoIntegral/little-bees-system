namespace :db do
  desc "Clean all data from database (keeps schema)"
  task clean_data: :environment do
    puts "🧹 Starting database cleanup..."

    # Disable foreign key checks temporarily
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF") if Rails.env.development?

    # Delete all records from all tables in order (respecting foreign keys)
    puts "Deleting sale_items..."
    SaleItem.delete_all

    puts "Deleting sales..."
    Sale.delete_all

    puts "Deleting customers..."
    Customer.delete_all

    puts "Deleting products..."
    Product.delete_all

    puts "Deleting discounts..."
    Discount.delete_all

    puts "Deleting users..."
    User.delete_all

    # Reset auto-increment sequences
    puts "Resetting ID sequences..."
    if Rails.env.development? # SQLite
      ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence")
    else # PostgreSQL
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.reset_pk_sequence!(table)
      end
    end

    # Re-enable foreign key checks
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON") if Rails.env.development?

    puts "✅ Database cleanup completed!"
    puts "📊 Current record counts:"
    puts "- Users: #{User.count}"
    puts "- Customers: #{Customer.count}"
    puts "- Products: #{Product.count}"
    puts "- Sales: #{Sale.count}"
    puts "- Sale Items: #{SaleItem.count}"
    puts "- Discounts: #{Discount.count}"
    puts ""
    puts "🎯 Database is now clean and ready for fresh data!"
  end
end