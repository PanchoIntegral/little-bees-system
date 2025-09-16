class RecalculateSaleTotals < ActiveRecord::Migration[7.2]
  def up
    # Recalculate all sales with items
    Sale.joins(:sale_items).distinct.find_each do |sale|
      # Skip sales with 0 subtotal (no items)
      next if sale.subtotal == 0
      
      # Calculate discount
      subtotal = sale.subtotal
      discount = if subtotal < 50
        0.0
      elsif subtotal >= 100
        subtotal * 0.10
      elsif subtotal >= 50
        subtotal * 0.05
      else
        0.0
      end
      
      # Calculate tax (8% on discounted amount)
      tax = (subtotal - discount) * 0.08
      
      # Calculate total
      total = subtotal + tax - discount
      
      # Update the sale directly in SQL to bypass callbacks
      Sale.where(id: sale.id).update_all(
        discount_amount: discount,
        tax_amount: tax,
        total_amount: total,
        updated_at: Time.current
      )
      
      puts "✅ Recalculated Sale ##{sale.id}: $#{subtotal} → $#{total}"
    end
    
    puts "🎉 All sales recalculated successfully!"
  end

  def down
    # This migration cannot be reversed safely
    raise ActiveRecord::IrreversibleMigration
  end
end
