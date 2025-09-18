import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { offersService, type Offer, type CreateOfferData, type OfferFilters, type ApplicableOffer } from '../services/offers'
import { useProductsStore } from './products'

export const useOffersStore = defineStore('offers', () => {
  // State
  const offers = ref<Offer[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // LocalStorage key
  const STORAGE_KEY = 'little-bees-offers'

  // Load offers from localStorage
  function loadOffersFromStorage(): Offer[] {
    try {
      const stored = localStorage.getItem(STORAGE_KEY)
      if (stored) {
        return JSON.parse(stored)
      }
    } catch (error) {
      console.error('Error loading offers from storage:', error)
    }
    return []
  }

  // Save offers to localStorage
  function saveOffersToStorage(offersData: Offer[]) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(offersData))
    } catch (error) {
      console.error('Error saving offers to storage:', error)
    }
  }

  // Getters/Computed
  const activeOffers = computed(() =>
    offers.value.filter(offer => offer.active === true)
  )

  const offersByProduct = computed(() => {
    // Since offers are now general (not by product), return empty object
    return {}
  })

  const offerStats = computed(() => {
    const total = offers.value.length
    const active = activeOffers.value.length

    // Calculate average discount for percentage offers
    const percentageOffers = offers.value.filter(o => o.discount_type === 'percentage')
    const averageDiscount = percentageOffers.length > 0
      ? percentageOffers.reduce((sum, o) => sum + o.discount_value, 0) / percentageOffers.length
      : 0

    return {
      total_offers: total,
      active_offers: active,
      average_discount: averageDiscount
    }
  })

  // Actions
  async function fetchOffers(filters?: OfferFilters) {
    loading.value = true
    error.value = null

    try {
      // Use the real backend API instead of localStorage
      const apiOffers = await offersService.getOffers(filters)

      // Clear localStorage to avoid conflicts
      localStorage.removeItem(STORAGE_KEY)

      const storedOffers = apiOffers

      // Apply filters if provided (filters are already applied in the backend call)
      offers.value = storedOffers
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Error fetching offers'
      console.error('Error fetching offers:', err)
    } finally {
      loading.value = false
    }
  }

  async function createOffer(data: CreateOfferData): Promise<Offer> {
    loading.value = true
    error.value = null

    try {
      // Use the backend service to create the offer
      const newOffer = await offersService.createOffer(data)

      // Add to local state
      offers.value.push(newOffer)

      return newOffer
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Error creating offer'
      console.error('Error creating offer:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateOffer(id: number, data: Partial<CreateOfferData>): Promise<Offer> {
    loading.value = true
    error.value = null

    try {
      // Use the backend service to update the offer
      const updatedOffer = await offersService.updateOffer(id, data)

      // Update local state
      const stateIndex = offers.value.findIndex(o => o.id === id)
      if (stateIndex !== -1) {
        offers.value[stateIndex] = updatedOffer
      }

      return updatedOffer
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Error updating offer'
      console.error('Error updating offer:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteOffer(id: number): Promise<void> {
    loading.value = true
    error.value = null

    try {
      // Use the real backend API to delete the offer
      await offersService.deleteOffer(id)

      // Remove from state
      const stateIndex = offers.value.findIndex(o => o.id === id)
      if (stateIndex !== -1) {
        offers.value.splice(stateIndex, 1)
      }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Error deleting offer'
      console.error('Error deleting offer:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function toggleOfferStatus(id: number): Promise<void> {
    try {
      // Use the backend service to toggle status
      const updatedOffer = await offersService.toggleOfferStatus(id)

      // Update local state
      const stateIndex = offers.value.findIndex(o => o.id === id)
      if (stateIndex !== -1) {
        offers.value[stateIndex] = updatedOffer
      }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Error toggling offer status'
      console.error('Error toggling offer status:', err)
      throw err
    }
  }

  async function getApplicableOffers(productId: number, quantity: number = 1): Promise<ApplicableOffer[]> {
    try {
      // Get all active offers for this product
      const productOffers = getOffersByProductId(productId)

      const applicableOffers: ApplicableOffer[] = []

      for (const offer of productOffers) {
        const product = useProductsStore().products.find(p => p.id === productId)
        if (!product) continue

        const result = calculateOfferDiscount(offer, product.price, quantity)

        if (result.applicable && result.discount_amount > 0) {
          applicableOffers.push({
            offer,
            discount_amount: result.discount_amount,
            final_price: result.final_price,
            savings: result.discount_amount
          })
        }
      }

      return applicableOffers
    } catch (err) {
      console.error('Error getting applicable offers:', err)
      return []
    }
  }

  async function calculateProductDiscount(productId: number, quantity: number, basePrice: number) {
    try {
      // Use the offers service to calculate discounts directly from backend
      const result = await offersService.calculateDiscount(productId, quantity, basePrice)
      return result
    } catch (err) {
      console.warn('Backend discount calculation failed, falling back to no discount:', err)
      return {
        original_total: basePrice * quantity,
        discount_amount: 0,
        final_total: basePrice * quantity,
        applied_offers: []
      }
    }
  }

  function getOfferById(id: number): Offer | undefined {
    return offers.value.find(offer => offer.id === id)
  }

  function getOffersByProductId(productId: number): Offer[] {
    // Since offers are now general, return all active offers
    return offers.value.filter(offer => offer.active === true)
  }

  function clearError() {
    error.value = null
  }

  // Utility function to clear all offers from storage (for testing/debugging)
  function clearAllOffers() {
    try {
      localStorage.removeItem(STORAGE_KEY)
      offers.value = []
      console.log('🧹 All offers cleared from localStorage')
    } catch (error) {
      console.error('Error clearing offers from storage:', error)
    }
  }

  // Force clear localStorage offers immediately on store creation
  clearAllOffers()

  // Helper functions for offer calculations
  function calculateOfferDiscount(offer: Offer, basePrice: number, quantity: number): {
    discount_amount: number
    final_price: number
    applicable: boolean
  } {
    let discount = 0
    let applicable = false
    const itemTotal = basePrice * quantity

    // Check if item total meets minimum amount
    if (itemTotal < offer.minimum_amount) {
      return { discount_amount: 0, final_price: basePrice, applicable: false }
    }

    switch (offer.discount_type) {
      case 'percentage':
        discount = (itemTotal * offer.discount_value) / 100
        applicable = true
        break

      case 'fixed_amount':
        discount = Math.min(offer.discount_value, itemTotal)
        applicable = true
        break
    }

    return {
      discount_amount: discount,
      final_price: itemTotal - discount,
      applicable
    }
  }

  function formatOfferDescription(offer: Offer): string {
    switch (offer.discount_type) {
      case 'percentage':
        return `${offer.discount_value}% de descuento`
      case 'fixed_amount':
        return `$${offer.discount_value} de descuento`
      default:
        return offer.description || 'Oferta especial'
    }
  }

  return {
    // State
    offers,
    loading,
    error,

    // Getters
    activeOffers,
    offersByProduct,
    offerStats,

    // Actions
    fetchOffers,
    createOffer,
    updateOffer,
    deleteOffer,
    toggleOfferStatus,
    getApplicableOffers,
    calculateProductDiscount,
    getOfferById,
    getOffersByProductId,
    clearError,
    clearAllOffers,

    // Helpers
    calculateOfferDiscount,
    formatOfferDescription
  }
})