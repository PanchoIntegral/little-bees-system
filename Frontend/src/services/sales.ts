import { apiService } from './api'
import { authService } from './auth'
import { Product } from './products'

export interface User {
  id: number
  email: string
  first_name: string
  last_name: string
  role: string
  full_name: string
}

export interface SaleItem {
  id: number
  quantity: number
  unit_price: number
  line_total: number
  product: Product
  created_at: string
  updated_at: string
}

export interface Sale {
  id: number
  total_amount: number
  tax_amount: number
  discount_amount: number
  status: 'pending' | 'completed' | 'cancelled' | 'refunded'
  payment_method: 'cash' | 'credit_card' | 'debit_card' | 'digital_wallet'
  notes?: string
  created_at: string
  updated_at: string
  receipt_number: string
  subtotal: number
  items_count: number
  formatted_total: string
  payment_method_display: string
  status_display: string
  customer_name: string
  user: User
  sale_items: SaleItem[]
}

export interface SaleFilters {
  search?: string
  status?: string
  payment_method?: string
  user_id?: number
  customer_id?: number
  start_date?: string
  end_date?: string
  date_filter?: 'today' | 'this_week' | 'this_month'
  min_amount?: number
  max_amount?: number
  sort_by?: 'created_at' | 'total_amount' | 'status' | 'payment_method' | 'customer_name'
  sort_direction?: 'asc' | 'desc'
  page?: number
  per_page?: number
  include_total?: boolean
}

export interface SaleResponse {
  sales: Sale[]
  pagination: PaginationMeta
  filters_applied?: Record<string, any>
}

// Re-export PaginationMeta from products
export type { PaginationMeta } from './products'

export interface CreateSaleData {
  status?: string
  payment_method: string
  notes?: string
  customer_id?: number
  anonymous_customer_name?: string | null
  discount_amount?: number
  applied_sale_offers?: {
    id: number;
    name: string;
    discount_type: string;
    discount_value: number;
  }[]
  sale_items_attributes?: {
    product_id: number;
    quantity: number;
    unit_price: number;
    applied_offers?: number[];
  }[];
}

export interface SaleItemData {
  product_id: number
  quantity: number
  unit_price?: number
}

export interface DashboardStats {
  today: {
    sales_count: number
    revenue: number
  }
  this_month: {
    sales_count: number
    revenue: number
  }
  average_sale: number
  recent_sales: Sale[]
  daily_sales: DailySales[]
}

export interface DailySales {
  date: string
  formatted_date: string
  short_date: string
  sales_count: number
  total_revenue: number
  sales: Sale[]
}

class SalesService {
  async getSales(filters: SaleFilters = {}): Promise<SaleResponse> {
    return apiService.get<SaleResponse>('/v1/sales', filters)
  }

  async getSale(id: number): Promise<Sale> {
    return apiService.get<Sale>(`/v1/sales/${id}`)
  }

  async createSale(data: CreateSaleData): Promise<Sale> {
    return apiService.post<Sale>('/v1/sales', { sale: data })
  }

  async updateSale(id: number, data: Partial<CreateSaleData>): Promise<Sale> {
    return apiService.put<Sale>(`/v1/sales/${id}`, { sale: data })
  }

  async deleteSale(id: number): Promise<{ message: string }> {
    return apiService.delete<{ message: string }>(`/v1/sales/${id}`)
  }

  async bulkDeleteSales(saleIds: number[]): Promise<{ message: string; deleted_count: number }> {
    const token = authService.getToken()
    if (!token) {
      throw new Error('Authentication token not found.')
    }

    const response = await fetch('http://localhost:3000/api/v1/sales/bulk_destroy', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ sale: { sale_ids: saleIds } })
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({ error: 'Failed to parse error response' }))
      throw new Error(errorData.error || `Request failed with status ${response.status}`)
    }

    return response.json()
  }

  async completeSale(id: number): Promise<Sale> {
    return apiService.patch<Sale>(`/v1/sales/${id}/complete`)
  }

  async cancelSale(id: number): Promise<Sale> {
    return apiService.patch<Sale>(`/v1/sales/${id}/cancel`)
  }

  async refundSale(id: number): Promise<Sale> {
    return apiService.patch<Sale>(`/v1/sales/${id}/refund`)
  }

  async addSaleItem(saleId: number, data: SaleItemData): Promise<Sale> {
    return apiService.post<Sale>(`/v1/sales/${saleId}/sale_items`, { sale_item: data })
  }

  async updateSaleItem(saleId: number, itemId: number, data: Partial<SaleItemData>): Promise<Sale> {
    return apiService.put<Sale>(`/v1/sales/${saleId}/sale_items/${itemId}`, { sale_item: data })
  }

  async removeSaleItem(saleId: number, itemId: number): Promise<Sale> {
    return apiService.delete<Sale>(`/v1/sales/${saleId}/sale_items/${itemId}`)
  }

  async getDashboardStats(): Promise<DashboardStats> {
    return apiService.get<DashboardStats>('/v1/sales/stats')
  }
}

export const salesService = new SalesService()