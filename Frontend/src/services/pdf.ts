import type { Sale } from './sales'
import QRCode from 'qrcode'

export interface ReceiptData {
  sale: Sale
  companyInfo: {
    name: string
    address: string
    phone: string
    email: string
    logoUrl?: string
  }
  qrDataUrl?: string
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
        email: "info@littlebeescandles.com",
        // You can replace this with your actual logo placed in Frontend/public/logo.png
        // or pass it dynamically when calling the service in the future.
        logoUrl: '/favicon.svg'
      }
    }

    // Pre-generate QR como data URL (offline)
    try {
      const content = `Recibo:${(sale as any).receipt_number || ''}|Total:${(sale as any).total_amount}|Fecha:${(sale as any).created_at}`
      receiptData.qrDataUrl = await QRCode.toDataURL(content, {
        width: 120,
        margin: 0,
        color: { dark: '#111111', light: '#00000000' }
      })
    } catch (err) {
      receiptData.qrDataUrl = undefined
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
    const discountValue = typeof (sale as any).discount_amount === 'string'
      ? parseFloat((sale as any).discount_amount)
      : ((sale as any).discount_amount || 0);
    const taxValue = typeof (sale as any).tax_amount === 'string'
      ? parseFloat((sale as any).tax_amount)
      : ((sale as any).tax_amount || 0);

    

    return `
      <!DOCTYPE html>
      <html lang="es">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Recibo - ${(sale as any).receipt_number || 'Venta'}</title>
          <style>
            :root { --primary:#111827; --muted:#6B7280; --border:#E5E7EB; --accent:#F59E0B; }
            * { box-sizing: border-box; }
            body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Apple Color Emoji", "Segoe UI Emoji"; margin:0; background:#f8fafc; color:#111827; }
            .page { width: 800px; max-width: 100%; margin: 24px auto; background:#fff; border:1px solid var(--border); border-radius:16px; overflow:hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.06); }
            .header { display:flex; align-items:center; justify-content:space-between; padding:24px 28px; border-bottom:1px solid var(--border); }
            .brand { display:flex; align-items:center; gap:16px; }
            .brand img { height:56px; width:auto; }
            .brand h1 { margin:0; font-size:20px; letter-spacing:1.2px; }
            .meta { text-align:right; font-size:13px; color:var(--muted); }
            .meta strong { color:#111827; font-size:14px; }
            .sections { display:grid; grid-template-columns: 1fr 1fr; gap:16px; padding:20px 28px; }
            .card { border:1px solid var(--border); border-radius:12px; padding:14px 16px; }
            .card h3 { margin:0 0 8px; font-size:13px; letter-spacing:.08em; color:var(--muted); text-transform:uppercase; }
            .card p { margin:4px 0; font-size:14px; }
            .items { padding:0 28px 8px; }
            table { width:100%; border-collapse:collapse; }
            thead th { font-size:12px; text-transform:uppercase; letter-spacing:.06em; color:var(--muted); text-align:left; padding:10px 8px; border-bottom:1px solid var(--border); }
            tbody td { padding:12px 8px; border-bottom:1px solid var(--border); font-size:14px; vertical-align:top; }
            tbody tr:last-child td { border-bottom:none; }
            .qty, .price, .amount { text-align:right; white-space:nowrap; }
            .totals { padding:12px 28px 24px; display:grid; grid-template-columns: 1fr 320px; gap:16px; align-items:start; }
            .summary { border:1px solid var(--border); border-radius:12px; padding:12px 16px; }
            .summary .row { display:flex; justify-content:space-between; margin:8px 0; font-size:14px; }
            .summary .total { font-weight:700; font-size:18px; border-top:1px dashed var(--border); padding-top:10px; }
            .notes { font-size:13px; color:var(--muted); }
            .qr { text-align:center; }
            .qr img { height:96px; width:96px; }
            .footer { padding:14px 28px 24px; border-top:1px solid var(--border); color:var(--muted); font-size:12px; display:flex; align-items:center; justify-content:space-between; }
            .badge { background: #FEF3C7; color:#92400E; border:1px solid #FDE68A; padding:4px 8px; border-radius:999px; font-size:12px; }
            @media print {
              body { background:#fff; }
              .page { width: 100%; margin: 0; border:none; box-shadow:none; border-radius:0; }
              .footer { page-break-inside:avoid; }
            }
          </style>
      </head>
      <body>
        <div class="page">
          <div class="header">
            <div class="brand">
              ${companyInfo.logoUrl ? `<img src="${companyInfo.logoUrl}" alt="logo" />` : ''}
              <div>
                <h1>${companyInfo.name}</h1>
                <div style="font-size:12px;color:var(--muted);">${companyInfo.address} · ${companyInfo.phone} · ${companyInfo.email}</div>
              </div>
            </div>
            <div class="meta">
              <div><strong>Recibo:</strong> ${(sale as any).receipt_number || (sale as any).id}</div>
              <div><strong>Fecha:</strong> ${this.formatDate((sale as any).created_at || new Date().toISOString())} ${this.formatTime((sale as any).created_at || new Date().toISOString())}</div>
              <div><span class="badge">${(sale as any).status || 'completed'}</span></div>
            </div>
          </div>

          <div class="sections">
            <div class="card">
              <h3>Cliente</h3>
              <p><strong>${(sale as any).customer?.first_name || ''} ${(sale as any).customer?.last_name || ''}</strong></p>
              <p>${(sale as any).customer?.email || ''}</p>
            </div>
            <div class="card">
              <h3>Pago</h3>
              <p>Método: <strong>${(sale as any).payment_method || '—'}</strong></p>
              <p>Atendido por: ${(sale as any).user?.first_name || ''} ${(sale as any).user?.last_name || ''}</p>
            </div>
          </div>

          <div class="items">
            <table>
              <thead>
                <tr>
                  <th>Producto</th>
                  <th class="qty">Cant.</th>
                  <th class="price">Precio</th>
                  <th class="amount">Importe</th>
                </tr>
              </thead>
              <tbody>
                ${((sale as any).sale_items || []).map((item: any) => `
                  <tr>
                    <td>
                      <div style="font-weight:600">${item.product?.name || ''}</div>
                      <div style="color:var(--muted); font-size:12px;">SKU: ${item.product?.sku || '-'}</div>
                    </td>
                    <td class="qty">${item.quantity || 0}</td>
                    <td class="price">$${this.formatCurrency(item.unit_price)}</td>
                    <td class="amount">$${this.formatCurrency(item.line_total)}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>

          <div class="totals">
            <div class="notes">
              ${((sale as any).notes || '').length ? `<strong>Notas:</strong> ${(sale as any).notes}` : ''}
            </div>
            <div class="summary">
              <div class="row"><span>Subtotal</span><span>$${this.formatCurrency((sale as any).subtotal)}</span></div>
              ${discountValue > 0 ? `<div class="row"><span>Descuento</span><span>- $${this.formatCurrency(discountValue)}</span></div>` : ''}
              <div class="row"><span>Impuestos</span><span>$${this.formatCurrency(taxValue)}</span></div>
              <div class="row total"><span>Total</span><span>$${this.formatCurrency((sale as any).total_amount)}</span></div>
            </div>
          </div>

          <div class="footer">
            <div>
              ¡Gracias por su compra! Síguenos en redes @littlebeescandles
            </div>
            <div class="qr">
              ${data.qrDataUrl ? `<img src="${data.qrDataUrl}" alt="QR" />` : ''}
            </div>
          </div>
        </div>
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
