import { apiService } from './api'
import type { Product } from './products'

export interface Offer {
  id: number
  name: string
  description: string
  discount_type: 'percentage' | 'fixed_amount'
  discount_value: number
  minimum_amount: number
  active: boolean
  starts_at: string | null
  ends_at: string | null
  created_at: string
  updated_at: string
  is_valid_now?: boolean
}

export interface CreateOfferData {
  name: string
  description?: string
  discount_type: 'percentage' | 'fixed_amount'
  discount_value: number
  minimum_amount?: number
  active?: boolean
  starts_at?: string
  ends_at?: string
}

export interface OfferFilters {
  search?: string
  discount_type?: string
  active?: boolean
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
      if (filters?.discount_type) params.append('discount_type', filters.discount_type)
      if (filters?.active !== undefined) params.append('active', filters.active.toString())

      const response = await apiService.get<{discounts: Offer[]}>(`/v1/discounts?${params.toString()}`)
      return response.discounts || []
    } catch (error) {
      console.error('Error fetching offers:', error)
      throw error
    }
  }

  // Get a single offer by ID
  async getOffer(id: number): Promise<Offer> {
    try {
      const response = await apiService.get<Offer>(`/v1/discounts/${id}`)
      return response
    } catch (error) {
      console.error('Error fetching offer:', error)
      throw error
    }
  }

  // Create a new offer
  async createOffer(data: CreateOfferData): Promise<Offer> {
    try {
      const response = await apiService.post<Offer>('/v1/discounts', { discount: data })
      return response
    } catch (error) {
      console.error('Error creating offer:', error)
      throw error
    }
  }

  // Update an existing offer
  async updateOffer(id: number, data: Partial<CreateOfferData>): Promise<Offer> {
    try {
      const response = await apiService.put<Offer>(`/v1/discounts/${id}`, { discount: data })
      return response
    } catch (error) {
      console.error('Error updating offer:', error)
      throw error
    }
  }

  // Delete an offer
  async deleteOffer(id: number): Promise<void> {
    try {
      await apiService.delete(`/v1/discounts/${id}`)
    } catch (error) {
      console.error('Error deleting offer:', error)
      throw error
    }
  }

  // Get applicable offers for a specific product
  async getApplicableOffers(productId: number, quantity: number = 1): Promise<ApplicableOffer[]> {
    try {
      // Get all active discounts and filter applicable ones
      const discounts = await this.getActiveDiscounts()
      const applicableOffers: ApplicableOffer[] = []

      for (const discount of discounts) {
        const itemTotal = quantity * 100 // Default price, will be calculated properly in frontend
        if (itemTotal >= discount.minimum_amount) {
          let discountAmount = 0
          if (discount.discount_type === 'percentage') {
            discountAmount = (itemTotal * discount.discount_value / 100)
          } else if (discount.discount_type === 'fixed_amount') {
            discountAmount = Math.min(discount.discount_value, itemTotal)
          }

          applicableOffers.push({
            offer: discount,
            discount_amount: discountAmount,
            final_price: itemTotal - discountAmount,
            savings: discountAmount
          })
        }
      }

      return applicableOffers
    } catch (error) {
      console.error('Error fetching applicable offers:', error)
      return []
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
      // Get all active discounts and calculate the best one
      const discounts = await this.getActiveDiscounts()
      const itemTotal = quantity * basePrice

      let bestDiscount = null
      let maxSavings = 0

      for (const discount of discounts) {
        if (itemTotal >= discount.minimum_amount) {
          let savings = 0
          if (discount.discount_type === 'percentage') {
            savings = (itemTotal * discount.discount_value / 100)
          } else if (discount.discount_type === 'fixed_amount') {
            savings = Math.min(discount.discount_value, itemTotal)
          }

          if (savings > maxSavings) {
            maxSavings = savings
            bestDiscount = discount
          }
        }
      }

      return {
        original_total: itemTotal,
        discount_amount: maxSavings,
        final_total: itemTotal - maxSavings,
        applied_offers: bestDiscount ? [{
          offer: bestDiscount,
          discount_amount: maxSavings,
          final_price: itemTotal - maxSavings,
          savings: maxSavings
        }] : []
      }
    } catch (error) {
      console.error('Error calculating discount:', error)
      return {
        original_total: quantity * basePrice,
        discount_amount: 0,
        final_total: quantity * basePrice,
        applied_offers: []
      }
    }
  }

  // Helper method to get active discounts
  async getActiveDiscounts(): Promise<Offer[]> {
    try {
      const response = await apiService.get<{discounts: Offer[]}>('/v1/discounts?active=true')
      return response.discounts || []
    } catch (error) {
      console.error('Error fetching active discounts:', error)
      return []
    }
  }

  // Toggle offer status (active/inactive)
  async toggleOfferStatus(id: number): Promise<Offer> {
    try {
      const offer = await this.getOffer(id)

      if (!offer) {
        throw new Error(`Offer with id ${id} not found`)
      }

      if (offer.active === undefined) {
        throw new Error(`Offer ${id} does not have active property: ${JSON.stringify(offer)}`)
      }

      const updatedOffer = await this.updateOffer(id, { active: !offer.active })
      return updatedOffer
    } catch (error) {
      console.error('Error toggling offer status:', error)
      throw error
    }
  }

  // Get offer statistics
  async getOfferStats(): Promise<{
    total_offers: number
    active_offers: number
    total_savings: number
    average_discount: number
  }> {
    try {
      const allOffers = await this.getOffers()
      const activeOffers = allOffers.filter(offer => offer.active)

      return {
        total_offers: allOffers.length,
        active_offers: activeOffers.length,
        total_savings: 0, // Would need actual sales data to calculate
        average_discount: activeOffers.reduce((sum, offer) => sum + offer.discount_value, 0) / (activeOffers.length || 1)
      }
    } catch (error) {
      console.error('Error fetching offer stats:', error)
      throw error
    }
  }
}

export const offersService = new OffersService()