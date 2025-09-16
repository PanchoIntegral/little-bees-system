import type { Sale } from './sales'

export interface ReceiptData {
  sale: Sale
  companyInfo: {
    name: string
    address: string
    phone: string
    email: string
  }
}

export class PDFService {
  
  /**
   * Generate a PDF receipt for a sale
   */
  static async generateReceipt(sale: Sale): Promise<void> {
    const receiptData: ReceiptData = {
      sale,
      companyInfo: {
        name: "Little Bee's Candle Co.",
        address: "123 Candle Street, Wax City, WC 12345",
        phone: "(555) 123-4567",
        email: "info@littlebeescandles.com"
      }
    }

    // Create HTML content for the receipt
    const htmlContent = this.generateReceiptHTML(receiptData)

    // Create a new window for printing
    const printWindow = window.open('', '_blank')
    if (!printWindow) {
      throw new Error('Unable to open print window. Please check your popup blocker.')
    }

    // Write the HTML content
    printWindow.document.write(htmlContent)
    printWindow.document.close()

    // Wait for the content to load, then print
    printWindow.onload = () => {
      printWindow.print()
      printWindow.close()
    }
  }

  /**
   * Generate HTML content for the receipt
   */
  private static generateReceiptHTML(data: ReceiptData): string {
    const { sale, companyInfo } = data;

    return `
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Receipt - ${sale.receipt_number}</title>
          <style>
              /* ... existing styles ... */
          </style>
      </head>
      <body>
          <!-- ... existing header and receipt info ... -->
          
          <div class="items-section">
              ${sale.sale_items
                .map(
                  (item) => `
                  <div class="item">
                      <div class="item-name">${item.product.name}</div>
                      <div class="item-details">
                          <span>${item.quantity} x ${this.formatCurrency(
                            item.unit_price
                          )}</span>
                          <span><strong>${this.formatCurrency(
                            item.line_total
                          )}</strong></span>
                      </div>
                  </div>
              `
                )
                .join("")}
          </div>
          
          <div class="totals">
              <div><span>Subtotal:</span><span>${this.formatCurrency(
                sale.subtotal
              )}</span></div>
              ${
                (typeof sale.discount_amount === "string"
                  ? parseFloat(sale.discount_amount)
                  : sale.discount_amount) > 0
                  ? `
                  <div class="discount-section">
                      <div class="discount-item">
                          <span>🎉 Descuentos:</span>
                          <span>-${this.formatCurrency(
                            sale.discount_amount
                          )}</span>
                      </div>
                  </div>
                  <div class="savings">¡Ahorras ${this.formatCurrency(
                    sale.discount_amount
                  )}!</div>
              `
                  : ""
              }
              <div><span>Impuestos:</span><span>${this.formatCurrency(
                sale.tax_amount
              )}</span></div>
              <div class="total-line">
                  <span>TOTAL:</span>
                  <span>${this.formatCurrency(sale.total_amount)}</span>
              </div>
          </div>
          
          <!-- ... existing footer ... -->
      </body>
      </html>
    `;
  }

  /**
   * Safely format currency values
   */
  private static formatCurrency(value: string | number): string {
    const num = typeof value === "string" ? parseFloat(value) : value;
    return (num || 0).toFixed(2);
  }

  /**
   * Format date for display
   */
  private static formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });
  }

  /**
   * Format time for display
   */
  private static formatTime(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleTimeString("es-ES", {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
  }

  /**
   * Download receipt as PDF (alternative method)
   * This would require a PDF library like jsPDF
   */
  static async downloadReceiptPDF(sale: Sale): Promise<void> {
    // For now, we'll use the print method
    // In the future, you could integrate jsPDF or similar library
    await this.generateReceipt(sale)
  }
}

export const pdfService = PDFService
