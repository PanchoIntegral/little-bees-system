import { apiService } from './api'

export interface Discount {
  id: number
  name: string
  description?: string
  discount_type: 'percentage' | 'fixed_amount'
  discount_value: number
  minimum_amount: number
  active: boolean
  starts_at?: string
  ends_at?: string
  created_at: string
  updated_at: string
  is_valid_now: boolean
}

export interface DiscountFilters {
  active?: boolean
  discount_type?: 'percentage' | 'fixed_amount'
  sort_by?: 'name' | 'discount_value' | 'created_at'
  page?: number
  per_page?: number
}

export interface DiscountResponse {
  discounts: Discount[]
  pagination: {
    current_page: number
    total_pages: number
    total_count: number
    per_page: number
  }
}

export interface CreateDiscountData {
  name: string
  description?: string
  discount_type: 'percentage' | 'fixed_amount'
  discount_value: number
  minimum_amount?: number
  active?: boolean
  starts_at?: string
  ends_at?: string
}

class DiscountsService {
  async getDiscounts(filters: DiscountFilters = {}): Promise<DiscountResponse> {
    return apiService.get<DiscountResponse>('/v1/discounts', filters)
  }

  async getDiscount(id: number): Promise<Discount> {
    return apiService.get<Discount>(`/v1/discounts/${id}`)
  }

  async createDiscount(data: CreateDiscountData): Promise<Discount> {
    return apiService.post<Discount>('/v1/discounts', { discount: data })
  }

  async updateDiscount(id: number, data: Partial<CreateDiscountData>): Promise<Discount> {
    return apiService.put<Discount>(`/v1/discounts/${id}`, { discount: data })
  }

  async deleteDiscount(id: number): Promise<{ message: string }> {
    return apiService.delete<{ message: string }>(`/v1/discounts/${id}`)
  }

  async getActiveDiscounts(): Promise<Discount[]> {
    const response = await this.getDiscounts({ active: true })
    return response.discounts.filter(d => d.is_valid_now)
  }
}

export const discountsService = new DiscountsService()