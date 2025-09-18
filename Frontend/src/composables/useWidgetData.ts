import { computed, ref, watch } from 'vue'
import { useSalesStore } from '../stores/sales'
import { useProductsStore } from '../stores/products'

interface WidgetDataSource {
  key: string
  fetch: () => Promise<any>
  dependencies?: string[]
  cacheTTL?: number
}

const dataCache = new Map<string, { data: any; timestamp: number; ttl: number }>()
const DEFAULT_TTL = 5 * 60 * 1000 // 5 minutes

export function useWidgetData(widgetId: string, dataSource: string) {
  const salesStore = useSalesStore()
  const productsStore = useProductsStore()

  const loading = ref(false)
  const error = ref<string | null>(null)
  const lastRefresh = ref<Date | null>(null)

  // Data providers registry
  const dataProviders: Record<string, WidgetDataSource> = {
    today_revenue: {
      key: 'sales_stats',
      fetch: () => salesStore.fetchDashboardStats(),
      cacheTTL: 2 * 60 * 1000 // 2 minutes for sales data
    },
    monthly_revenue: {
      key: 'sales_stats',
      fetch: () => salesStore.fetchDashboardStats(),
      cacheTTL: 5 * 60 * 1000
    },
    average_sale: {
      key: 'sales_stats',
      fetch: () => salesStore.fetchDashboardStats(),
      cacheTTL: 5 * 60 * 1000
    },
    inventory_alerts: {
      key: 'products',
      fetch: () => productsStore.fetchProducts({ per_page: 100 }),
      cacheTTL: 10 * 60 * 1000 // 10 minutes for inventory data
    },
    daily_sales: {
      key: 'sales_stats',
      fetch: () => salesStore.fetchDashboardStats(),
      cacheTTL: 5 * 60 * 1000
    },
    payment_methods: {
      key: 'sales_stats',
      fetch: () => salesStore.fetchDashboardStats(),
      cacheTTL: 10 * 60 * 1000
    }
  }

  // Check if data is cached and still valid
  function isCacheValid(key: string): boolean {
    const cached = dataCache.get(key)
    if (!cached) return false

    const now = Date.now()
    return (now - cached.timestamp) < cached.ttl
  }

  // Get cached data
  function getCachedData(key: string): any {
    const cached = dataCache.get(key)
    return cached?.data
  }

  // Set cache
  function setCache(key: string, data: any, ttl: number = DEFAULT_TTL): void {
    dataCache.set(key, {
      data,
      timestamp: Date.now(),
      ttl
    })
  }

  // Clear cache for a specific key
  function clearCache(key?: string): void {
    if (key) {
      dataCache.delete(key)
    } else {
      dataCache.clear()
    }
  }

  // Get data with caching
  async function fetchData(forceRefresh = false): Promise<void> {
    const provider = dataProviders[dataSource]
    if (!provider) {
      error.value = `Unknown data source: ${dataSource}`
      return
    }

    // Check cache first
    if (!forceRefresh && isCacheValid(provider.key)) {
      return
    }

    loading.value = true
    error.value = null

    try {
      await provider.fetch()
      lastRefresh.value = new Date()

      // Cache the result
      const dataToCache = getStoreData(dataSource)
      setCache(provider.key, dataToCache, provider.cacheTTL)
    } catch (err: any) {
      error.value = err.message || `Failed to fetch data for ${dataSource}`
      console.error(`Error fetching data for widget ${widgetId}:`, err)
    } finally {
      loading.value = false
    }
  }

  // Get data from appropriate store
  function getStoreData(source: string): any {
    switch (source) {
      case 'today_revenue':
      case 'monthly_revenue':
      case 'average_sale':
      case 'daily_sales':
      case 'payment_methods':
        return salesStore.dashboardStats
      case 'inventory_alerts':
        return {
          lowStock: productsStore.lowStockProducts,
          outOfStock: productsStore.outOfStockProducts
        }
      default:
        return null
    }
  }

  // Computed data based on data source
  const data = computed(() => {
    const provider = dataProviders[dataSource]
    if (!provider) return null

    // Try cache first
    if (isCacheValid(provider.key)) {
      return getCachedData(provider.key)
    }

    // Fallback to store data
    return getStoreData(dataSource)
  })

  // Specific computed values
  const value = computed(() => {
    switch (dataSource) {
      case 'today_revenue':
        return salesStore.dashboardStats?.today?.revenue || 0
      case 'monthly_revenue':
        return salesStore.dashboardStats?.this_month?.revenue || 0
      case 'average_sale':
        return salesStore.dashboardStats?.average_sale || 0
      case 'inventory_alerts':
        return (productsStore.lowStockProducts?.length || 0) + (productsStore.outOfStockProducts?.length || 0)
      default:
        return 0
    }
  })

  const formattedValue = computed(() => {
    if (['today_revenue', 'monthly_revenue', 'average_sale'].includes(dataSource)) {
      return `$${formatCurrency(value.value)}`
    }
    return value.value.toString()
  })

  const subtitle = computed(() => {
    switch (dataSource) {
      case 'today_revenue':
        return `${salesStore.dashboardStats?.today?.sales_count || 0} ventas`
      case 'monthly_revenue':
        return `${salesStore.dashboardStats?.this_month?.sales_count || 0} ventas`
      case 'average_sale':
        return 'Por transacción'
      case 'inventory_alerts':
        return 'Items need attention'
      default:
        return 'No data'
    }
  })

  const isLoading = computed(() => {
    if (dataSource === 'inventory_alerts') {
      return productsStore.loading
    }
    return salesStore.loading
  })

  const hasError = computed(() => {
    if (error.value) return error.value

    if (dataSource === 'inventory_alerts') {
      return productsStore.error
    }
    return salesStore.error
  })

  // Auto-refresh functionality
  let refreshInterval: NodeJS.Timeout | null = null

  function startAutoRefresh(intervalMs: number = 5 * 60 * 1000): void {
    stopAutoRefresh()
    refreshInterval = setInterval(() => {
      fetchData(false) // Use cache if valid
    }, intervalMs)
  }

  function stopAutoRefresh(): void {
    if (refreshInterval) {
      clearInterval(refreshInterval)
      refreshInterval = null
    }
  }

  // Utility functions
  function formatCurrency(amount: number): string {
    return amount.toLocaleString('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }

  function refresh(): Promise<void> {
    return fetchData(true)
  }

  // Watch for widget id changes to reset state
  watch(() => widgetId, () => {
    error.value = null
    lastRefresh.value = null
  })

  return {
    // Data
    data,
    value,
    formattedValue,
    subtitle,

    // State
    loading: isLoading,
    error: hasError,
    lastRefresh,

    // Methods
    fetchData,
    refresh,
    clearCache,
    startAutoRefresh,
    stopAutoRefresh,

    // Utilities
    formatCurrency,
    isCacheValid: () => {
      const provider = dataProviders[dataSource]
      return provider ? isCacheValid(provider.key) : false
    }
  }
}

// Global cache management
export function useWidgetDataCache() {
  return {
    clearAll: () => dataCache.clear(),
    clearKey: (key: string) => dataCache.delete(key),
    getKeys: () => Array.from(dataCache.keys()),
    getSize: () => dataCache.size,

    // Cache stats
    getStats: () => {
      const now = Date.now()
      const stats = Array.from(dataCache.entries()).map(([key, value]) => ({
        key,
        age: now - value.timestamp,
        ttl: value.ttl,
        valid: (now - value.timestamp) < value.ttl
      }))

      return {
        total: stats.length,
        valid: stats.filter(s => s.valid).length,
        expired: stats.filter(s => !s.valid).length,
        details: stats
      }
    }
  }
}