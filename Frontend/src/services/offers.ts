import { apiService } from './api'
import type { Product } from './products'

export interface Offer {
  id: number
  name: string
  description: string
  type: 'percentage' | 'fixed' | 'buy_x_get_y' | 'bundle'
  status: 'active' | 'inactive' | 'scheduled' | 'expired'
  product_id: number
  product?: Product

  // Percentage discount
  discount_percentage?: number
  max_discount_amount?: number

  // Fixed discount
  discount_amount?: number

  // Buy X Get Y
  buy_quantity?: number
  get_quantity?: number

  // Bundle
  bundle_price?: number
  bundle_quantity?: number

  // Date range
  start_date: string
  end_date: string

  // Conditions
  minimum_purchase?: number
  usage_limit?: number
  limit_per_customer?: number
  stackable?: boolean

  // Timestamps
  created_at: string
  updated_at: string
}

export interface CreateOfferData {
  name: string
  description?: string
  type: 'percentage' | 'fixed' | 'buy_x_get_y' | 'bundle'
  product_id: number

  // Type-specific fields
  discount_percentage?: number
  max_discount_amount?: number
  discount_amount?: number
  buy_quantity?: number
  get_quantity?: number
  bundle_price?: number
  bundle_quantity?: number

  // Date range
  start_date: string
  end_date: string

  // Conditions
  minimum_purchase?: number
  usage_limit?: number
  limit_per_customer?: number
  stackable?: boolean
  status?: 'active' | 'inactive' | 'scheduled'
}

export interface OfferFilters {
  search?: string
  type?: string
  status?: string
  product_id?: number
}

export interface ApplicableOffer {
  offer: Offer
  discount_amount: number
  final_price: number
  savings: number
}

class OffersService {
  // Get all offers with optional filters
  async getOffers(filters?: OfferFilters): Promise<Offer[]> {
    try {
      const params = new URLSearchParams()
      if (filters?.search) params.append('search', filters.search)
      if (filters?.type) params.append('type', filters.type)
      if (filters?.status) params.append('status', filters.status)
      if (filters?.product_id) params.append('product_id', filters.product_id.toString())

      const response = await apiService.get(`/offers?${params.toString()}`)
      return response.data
    } catch (error) {
      console.error('Error fetching offers:', error)
      throw error
    }
  }

  // Get a single offer by ID
  async getOffer(id: number): Promise<Offer> {
    try {
      const response = await apiService.get(`/offers/${id}`)
      return response.data
    } catch (error) {
      console.error('Error fetching offer:', error)
      throw error
    }
  }

  // Create a new offer
  async createOffer(data: CreateOfferData): Promise<Offer> {
    try {
      const response = await apiService.post('/offers', data)
      return response.data
    } catch (error) {
      console.error('Error creating offer:', error)
      throw error
    }
  }

  // Update an existing offer
  async updateOffer(id: number, data: Partial<CreateOfferData>): Promise<Offer> {
    try {
      const response = await apiService.put(`/offers/${id}`, data)
      return response.data
    } catch (error) {
      console.error('Error updating offer:', error)
      throw error
    }
  }

  // Delete an offer
  async deleteOffer(id: number): Promise<void> {
    try {
      await apiService.delete(`/offers/${id}`)
    } catch (error) {
      console.error('Error deleting offer:', error)
      throw error
    }
  }

  // Get applicable offers for a specific product
  async getApplicableOffers(productId: number, quantity: number = 1): Promise<ApplicableOffer[]> {
    try {
      const response = await apiService.get(`/offers/applicable/${productId}?quantity=${quantity}`)
      return response.data
    } catch (error) {
      console.error('Error fetching applicable offers:', error)
      throw error
    }
  }

  // Calculate discount for a product with offers
  async calculateDiscount(productId: number, quantity: number, basePrice: number): Promise<{
    original_total: number
    discount_amount: number
    final_total: number
    applied_offers: ApplicableOffer[]
  }> {
    try {
      const response = await apiService.post('/offers/calculate-discount', {
        product_id: productId,
        quantity: quantity,
        base_price: basePrice
      })
      return response.data
    } catch (error) {
      console.error('Error calculating discount:', error)
      throw error
    }
  }

  // Toggle offer status (active/inactive)
  async toggleOfferStatus(id: number): Promise<Offer> {
    try {
      const response = await apiService.patch(`/offers/${id}/toggle-status`)
      return response.data
    } catch (error) {
      console.error('Error toggling offer status:', error)
      throw error
    }
  }

  // Get offer statistics
  async getOfferStats(): Promise<{
    total_offers: number
    active_offers: number
    products_with_offers: number
    total_savings: number
    average_discount: number
  }> {
    try {
      const response = await apiService.get('/offers/stats')
      return response.data
    } catch (error) {
      console.error('Error fetching offer stats:', error)
      throw error
    }
  }
}

export const offersService = new OffersService()