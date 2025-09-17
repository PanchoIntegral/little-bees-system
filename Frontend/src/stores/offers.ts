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
    offers.value.filter(offer => offer.status === 'active')
  )

  const offersByProduct = computed(() => {
    const groupedOffers: Record<number, Offer[]> = {}
    offers.value.forEach(offer => {
      if (!groupedOffers[offer.product_id]) {
        groupedOffers[offer.product_id] = []
      }
      groupedOffers[offer.product_id].push(offer)
    })
    return groupedOffers
  })

  const offerStats = computed(() => {
    const total = offers.value.length
    const active = activeOffers.value.length
    const productsWithOffers = new Set(offers.value.map(o => o.product_id)).size

    // Calculate average discount for percentage offers
    const percentageOffers = offers.value.filter(o => o.type === 'percentage' && o.discount_percentage)
    const averageDiscount = percentageOffers.length > 0
      ? percentageOffers.reduce((sum, o) => sum + (o.discount_percentage || 0), 0) / percentageOffers.length
      : 0

    return {
      total_offers: total,
      active_offers: active,
      products_with_offers: productsWithOffers,
      average_discount: averageDiscount
    }
  })

  // Actions
  async function fetchOffers(filters?: OfferFilters) {
    loading.value = true
    error.value = null

    try {
      // For now, load from localStorage (simulate API call)
      await new Promise(resolve => setTimeout(resolve, 300)) // Simulate network delay
      const storedOffers = loadOffersFromStorage()

      // Enrich offers with product information if missing
      const productsStore = useProductsStore()
      const enrichedOffers = storedOffers.map(offer => {
        if (!offer.product && offer.product_id) {
          const product = productsStore.products.find(p => p.id === offer.product_id)
          return { ...offer, product }
        }
        return offer
      })

      // Apply filters if provided
      let filteredOffers = enrichedOffers
      if (filters) {
        filteredOffers = enrichedOffers.filter(offer => {
          if (filters.search && !offer.name.toLowerCase().includes(filters.search.toLowerCase())) {
            return false
          }
          if (filters.type && offer.type !== filters.type) {
            return false
          }
          if (filters.status && offer.status !== filters.status) {
            return false
          }
          if (filters.product_id && offer.product_id !== filters.product_id) {
            return false
          }
          return true
        })
      }

      offers.value = filteredOffers
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
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500))

      // Get product information
      const productsStore = useProductsStore()
      const product = productsStore.products.find(p => p.id === data.product_id)

      // Create new offer with generated ID and timestamps
      const newOffer: Offer = {
        ...data,
        id: Date.now(), // Generate unique ID
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        status: data.status || 'active',
        product: product // Include product information
      }

      // Load current offers from storage
      const currentOffers = loadOffersFromStorage()
      currentOffers.push(newOffer)

      // Save to storage and update state
      saveOffersToStorage(currentOffers)
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
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500))

      // Load current offers from storage
      const currentOffers = loadOffersFromStorage()
      const index = currentOffers.findIndex(o => o.id === id)

      if (index === -1) {
        throw new Error('Offer not found')
      }

      // Update offer
      const updatedOffer: Offer = {
        ...currentOffers[index],
        ...data,
        updated_at: new Date().toISOString()
      }

      currentOffers[index] = updatedOffer

      // Save to storage and update state
      saveOffersToStorage(currentOffers)
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
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 300))

      // Load current offers from storage
      const currentOffers = loadOffersFromStorage()
      const index = currentOffers.findIndex(o => o.id === id)

      if (index === -1) {
        throw new Error('Offer not found')
      }

      // Remove from storage
      currentOffers.splice(index, 1)
      saveOffersToStorage(currentOffers)

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
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 300))

      // Load current offers from storage
      const currentOffers = loadOffersFromStorage()
      const index = currentOffers.findIndex(o => o.id === id)

      if (index === -1) {
        throw new Error('Offer not found')
      }

      // Toggle status
      const currentOffer = currentOffers[index]
      const newStatus = currentOffer.status === 'active' ? 'inactive' : 'active'

      const updatedOffer: Offer = {
        ...currentOffer,
        status: newStatus,
        updated_at: new Date().toISOString()
      }

      currentOffers[index] = updatedOffer

      // Save to storage and update state
      saveOffersToStorage(currentOffers)
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
      // Get all active offers for this product
      const productOffers = getOffersByProductId(productId)

      if (productOffers.length === 0) {
        return {
          original_total: basePrice * quantity,
          discount_amount: 0,
          final_total: basePrice * quantity,
          applied_offers: []
        }
      }

      const originalTotal = basePrice * quantity
      let totalDiscount = 0
      const appliedOffers: any[] = []

      // Apply each offer and find the best discount
      for (const offer of productOffers) {
        const result = calculateOfferDiscount(offer, basePrice, quantity)

        if (result.applicable && result.discount_amount > 0) {
          // For now, we'll apply the best single discount (not stack)
          if (result.discount_amount > totalDiscount) {
            totalDiscount = result.discount_amount
            appliedOffers.length = 0 // Clear previous offers
            appliedOffers.push({
              id: offer.id,
              name: offer.name,
              discount_amount: result.discount_amount,
              savings: result.discount_amount
            })
          }
        }
      }

      return {
        original_total: originalTotal,
        discount_amount: totalDiscount,
        final_total: originalTotal - totalDiscount,
        applied_offers: appliedOffers
      }
    } catch (err) {
      console.error('Error calculating discount:', err)
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
    return offers.value.filter(offer =>
      offer.product_id === productId && offer.status === 'active'
    )
  }

  function clearError() {
    error.value = null
  }

  // Utility function to clear all offers from storage (for testing/debugging)
  function clearAllOffers() {
    try {
      localStorage.removeItem(STORAGE_KEY)
      offers.value = []
    } catch (error) {
      console.error('Error clearing offers from storage:', error)
    }
  }

  // Helper functions for offer calculations
  function calculateOfferDiscount(offer: Offer, basePrice: number, quantity: number): {
    discount_amount: number
    final_price: number
    applicable: boolean
  } {
    let discount = 0
    let applicable = false

    switch (offer.type) {
      case 'percentage':
        if (offer.discount_percentage) {
          discount = (basePrice * quantity * offer.discount_percentage) / 100
          if (offer.max_discount_amount && discount > offer.max_discount_amount) {
            discount = offer.max_discount_amount
          }
          applicable = true
        }
        break

      case 'fixed':
        if (offer.discount_amount) {
          discount = Math.min(offer.discount_amount, basePrice * quantity)
          applicable = true
        }
        break

      case 'buy_x_get_y':
        if (offer.buy_quantity && offer.get_quantity && quantity >= offer.buy_quantity) {
          const setsOffers = Math.floor(quantity / offer.buy_quantity)
          const freeItems = setsOffers * offer.get_quantity
          discount = Math.min(freeItems, quantity) * basePrice
          applicable = true
        }
        break

      case 'bundle':
        if (offer.bundle_price && offer.bundle_quantity && quantity >= offer.bundle_quantity) {
          const bundleSets = Math.floor(quantity / offer.bundle_quantity)
          const originalCost = bundleSets * offer.bundle_quantity * basePrice
          const bundleCost = bundleSets * offer.bundle_price
          discount = originalCost - bundleCost
          applicable = true
        }
        break
    }

    return {
      discount_amount: discount,
      final_price: basePrice - (discount / quantity),
      applicable
    }
  }

  function formatOfferDescription(offer: Offer): string {
    switch (offer.type) {
      case 'percentage':
        return `${offer.discount_percentage}% de descuento`
      case 'fixed':
        return `$${offer.discount_amount} de descuento`
      case 'buy_x_get_y':
        return `Compra ${offer.buy_quantity}, lleva ${offer.get_quantity} gratis`
      case 'bundle':
        return `Paquete de ${offer.bundle_quantity} por $${offer.bundle_price}`
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