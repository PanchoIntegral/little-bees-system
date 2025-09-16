<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h1 class="text-3xl font-bold text-gray-900">📊 Dashboard</h1>
      <div class="text-sm text-gray-500">
        {{ new Date().toLocaleDateString('en-US', {
          weekday: 'long',
          year: 'numeric',
          month: 'long',
          day: 'numeric'
        }) }}
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="salesStore.loading && !salesStore.dashboardStats" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="salesStore.error" class="bg-red-50 border border-red-200 rounded-md p-4">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error loading dashboard</h3>
          <div class="mt-2 text-sm text-red-700">
            <p>{{ salesStore.error }}</p>
          </div>
          <div class="mt-4">
            <button
              @click="loadDashboard"
              class="btn btn-secondary"
            >
              Try again
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Dashboard Content -->
    <div v-else>
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <!-- Today's Sales -->
        <div class="card">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
                </svg>
              </div>
            </div>
            <div class="ml-4">
              <h3 class="text-sm font-medium text-gray-900">Today's Revenue</h3>
              <p class="text-2xl font-semibold text-gray-900">
                ${{ formatCurrency(salesStore.dashboardStats?.today?.revenue || 0) }}
              </p>
              <p class="text-sm text-gray-500">
                {{ salesStore.dashboardStats?.today?.sales_count || 0 }} sales
              </p>
            </div>
          </div>
        </div>

        <!-- Monthly Sales -->
        <div class="card">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
                </svg>
              </div>
            </div>
            <div class="ml-4">
              <h3 class="text-sm font-medium text-gray-900">This Month</h3>
              <p class="text-2xl font-semibold text-gray-900">
                ${{ formatCurrency(salesStore.dashboardStats?.this_month?.revenue || 0) }}
              </p>
              <p class="text-sm text-gray-500">
                {{ salesStore.dashboardStats?.this_month?.sales_count || 0 }} sales
              </p>
            </div>
          </div>
        </div>

        <!-- Average Sale -->
        <div class="card">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-yellow-100 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                </svg>
              </div>
            </div>
            <div class="ml-4">
              <h3 class="text-sm font-medium text-gray-900">Average Sale</h3>
              <p class="text-2xl font-semibold text-gray-900">
                ${{ formatCurrency(salesStore.dashboardStats?.average_sale || 0) }}
              </p>
              <p class="text-sm text-gray-500">Per transaction</p>
            </div>
          </div>
        </div>

        <!-- Inventory Alerts -->
        <div class="card">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.93-.833-2.464 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                </svg>
              </div>
            </div>
            <div class="ml-4">
              <h3 class="text-sm font-medium text-gray-900">Inventory Alerts</h3>
              <p class="text-2xl font-semibold text-gray-900">
                {{ productsStore.lowStockCount + productsStore.outOfStockCount }}
              </p>
              <p class="text-sm text-gray-500">Items need attention</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Activity & Alerts -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Recent Sales -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Recent Sales</h3>
            <router-link to="/sales" class="text-sm text-primary-600 hover:text-primary-500">
              View all
            </router-link>
          </div>

          <div v-if="salesStore.dashboardStats?.recent_sales?.length" class="space-y-3">
            <div
              v-for="sale in salesStore.dashboardStats.recent_sales"
              :key="sale.id"
              class="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0"
            >
              <div>
                <p class="text-sm font-medium text-gray-900">{{ sale.receipt_number }}</p>
                <p class="text-xs text-gray-500">{{ sale.customer_name }}</p>
                <p class="text-xs text-gray-500">{{ formatDateTime(sale.created_at) }}</p>
              </div>
              <div class="text-right">
                <p class="text-sm font-medium text-gray-900">{{ sale.formatted_total }}</p>
                <span
                  class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                  :class="{
                    'bg-green-100 text-green-800': sale.status === 'completed',
                    'bg-yellow-100 text-yellow-800': sale.status === 'pending',
                    'bg-red-100 text-red-800': sale.status === 'cancelled',
                    'bg-gray-100 text-gray-800': sale.status === 'refunded'
                  }"
                >
                  {{ sale.status_display }}
                </span>
              </div>
            </div>
          </div>

          <div v-else class="text-center py-8">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No recent sales</h3>
            <p class="mt-1 text-sm text-gray-500">Start making sales to see them here.</p>
            <div class="mt-6">
              <router-link to="/sales" class="btn btn-primary">
                Create Sale
              </router-link>
            </div>
          </div>
        </div>

        <!-- Inventory Alerts -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Inventory Alerts</h3>
            <router-link to="/products" class="text-sm text-primary-600 hover:text-primary-500">
              View all
            </router-link>
          </div>

          <div v-if="inventoryAlerts.length" class="space-y-3">
            <div
              v-for="product in inventoryAlerts"
              :key="product.id"
              class="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0"
            >
              <div>
                <p class="text-sm font-medium text-gray-900">{{ product.name }}</p>
                <p class="text-xs text-gray-500">SKU: {{ product.sku }}</p>
              </div>
              <div class="text-right">
                <span
                  class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                  :class="{
                    'bg-yellow-100 text-yellow-800': product.stock_status === 'low_stock',
                    'bg-red-100 text-red-800': product.stock_status === 'out_of_stock'
                  }"
                >
                  {{ product.stock_quantity }} left
                  <span v-if="product.out_of_stock || product.low_stock"> ⚠️</span>
                </span>
              </div>
            </div>
          </div>

          <div v-else class="text-center py-8">
            <svg class="mx-auto h-12 w-12 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">All products in stock</h3>
            <p class="mt-1 text-sm text-gray-500">No inventory alerts at this time.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useSalesStore } from '../stores/sales'
import { useProductsStore } from '../stores/products'

const salesStore = useSalesStore()
const productsStore = useProductsStore()

// Computed
const inventoryAlerts = computed(() => [
  ...productsStore.lowStockProducts,
  ...productsStore.outOfStockProducts
].slice(0, 5)) // Show only first 5 alerts

// Methods
function formatCurrency(amount: number): string {
  return amount.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function formatDateTime(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

async function loadDashboard() {
  await Promise.all([
    salesStore.fetchDashboardStats(),
    productsStore.fetchProducts({ per_page: 100 }) // Load products for inventory alerts
  ])
}

// Lifecycle
onMounted(() => {
  loadDashboard()
})
</script>