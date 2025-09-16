import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { salesService, Sale, SaleFilters, CreateSaleData, SaleItemData, DashboardStats } from '../services/sales'

export const useSalesStore = defineStore('sales', () => {
  // State
  const sales = ref<Sale[]>([])
  const currentSale = ref<Sale | null>(null)
  const dashboardStats = ref<DashboardStats | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const pagination = ref({
    current_page: 1,
    total_pages: 1,
    total_count: 0,
    per_page: 20
  })

  // Getters
  const pendingSales = computed(() =>
    sales.value.filter(sale => sale.status === 'pending')
  )

  const completedSales = computed(() =>
    sales.value.filter(sale => sale.status === 'completed')
  )

  const todayRevenue = computed(() =>
    dashboardStats.value?.today.revenue || 0
  )

  const monthlyRevenue = computed(() =>
    dashboardStats.value?.this_month.revenue || 0
  )

  // Actions
  async function fetchSales(filters: SaleFilters = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await salesService.getSales(filters)
      sales.value = response.sales
      pagination.value = response.pagination
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch sales'
      console.error('Error fetching sales:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchSale(id: number) {
    loading.value = true
    error.value = null

    try {
      currentSale.value = await salesService.getSale(id)
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch sale'
      console.error('Error fetching sale:', err)
    } finally {
      loading.value = false
    }
  }

  async function createSale(data: CreateSaleData) {
    loading.value = true
    error.value = null

    try {
      const newSale = await salesService.createSale(data)
      sales.value.unshift(newSale)
      currentSale.value = newSale
      return newSale
    } catch (err: any) {
      error.value = err.response?.data?.errors || err.response?.data?.error || 'Failed to create sale'
      console.error('Error creating sale:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateSale(id: number, data: Partial<CreateSaleData>) {
    loading.value = true
    error.value = null

    try {
      const updatedSale = await salesService.updateSale(id, data)
      const index = sales.value.findIndex(s => s.id === id)
      if (index !== -1) {
        sales.value[index] = updatedSale
      }
      if (currentSale.value?.id === id) {
        currentSale.value = updatedSale
      }
      return updatedSale
    } catch (err: any) {
      error.value = err.response?.data?.errors || err.response?.data?.error || 'Failed to update sale'
      console.error('Error updating sale:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteSale(id: number) {
    loading.value = true
    error.value = null

    try {
      await salesService.deleteSale(id)
      sales.value = sales.value.filter(s => s.id !== id)
      if (currentSale.value?.id === id) {
        currentSale.value = null
      }
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to delete sale'
      console.error('Error deleting sale:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function completeSale(id: number) {
    loading.value = true
    error.value = null

    try {
      const completedSale = await salesService.completeSale(id)
      const index = sales.value.findIndex(s => s.id === id)
      if (index !== -1) {
        sales.value[index] = completedSale
      }
      if (currentSale.value?.id === id) {
        currentSale.value = completedSale
      }
      return completedSale
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to complete sale'
      console.error('Error completing sale:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function cancelSale(id: number) {
    loading.value = true
    error.value = null

    try {
      const cancelledSale = await salesService.cancelSale(id)
      const index = sales.value.findIndex(s => s.id === id)
      if (index !== -1) {
        sales.value[index] = cancelledSale
      }
      if (currentSale.value?.id === id) {
        currentSale.value = cancelledSale
      }
      return cancelledSale
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to cancel sale'
      console.error('Error cancelling sale:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function addSaleItem(saleId: number, data: SaleItemData) {
    loading.value = true
    error.value = null

    try {
      const updatedSale = await salesService.addSaleItem(saleId, data)
      const index = sales.value.findIndex(s => s.id === saleId)
      if (index !== -1) {
        sales.value[index] = updatedSale
      }
      if (currentSale.value?.id === saleId) {
        currentSale.value = updatedSale
      }
      return updatedSale
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to add item to sale'
      console.error('Error adding sale item:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function removeSaleItem(saleId: number, itemId: number) {
    loading.value = true
    error.value = null

    try {
      const updatedSale = await salesService.removeSaleItem(saleId, itemId)
      const index = sales.value.findIndex(s => s.id === saleId)
      if (index !== -1) {
        sales.value[index] = updatedSale
      }
      if (currentSale.value?.id === saleId) {
        currentSale.value = updatedSale
      }
      return updatedSale
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to remove item from sale'
      console.error('Error removing sale item:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchDashboardStats() {
    loading.value = true
    error.value = null

    try {
      dashboardStats.value = await salesService.getDashboardStats()
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch dashboard stats'
      console.error('Error fetching dashboard stats:', err)
    } finally {
      loading.value = false
    }
  }

  function clearError() {
    error.value = null
  }

  function clearCurrentSale() {
    currentSale.value = null
  }

  return {
    // State
    sales,
    currentSale,
    dashboardStats,
    loading,
    error,
    pagination,

    // Getters
    pendingSales,
    completedSales,
    todayRevenue,
    monthlyRevenue,

    // Actions
    fetchSales,
    fetchSale,
    createSale,
    updateSale,
    deleteSale,
    completeSale,
    cancelSale,
    addSaleItem,
    removeSaleItem,
    fetchDashboardStats,
    clearError,
    clearCurrentSale
  }
})