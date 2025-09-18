<template>
  <div class="simple-dashboard p-6">
    <!-- Dashboard Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <div class="flex items-center">
          <ChartBarIcon class="w-8 h-8 text-amber-500 mr-3" />
          <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
        </div>
        <p class="text-sm text-gray-500 mt-1">
          {{ currentDate }}
        </p>
      </div>

      <div class="flex items-center space-x-3">
        <button
          @click="isEditMode = !isEditMode"
          class="btn"
          :class="isEditMode ? 'btn-secondary' : 'btn-primary'"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!isEditMode" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
          {{ isEditMode ? 'Guardar Cambios' : 'Editar Dashboard' }}
        </button>

        <!-- Widget Settings Button (only in edit mode) -->
        <div v-if="isEditMode" class="relative">
          <button
            @click="showWidgetSettings = !showWidgetSettings"
            class="btn btn-outline"
            :class="{ 'btn-secondary': showWidgetSettings }"
          >
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4"></path>
            </svg>
            Configurar Widgets
          </button>

          <!-- Widget Settings Dropdown -->
          <div
            v-if="showWidgetSettings"
            class="absolute right-0 mt-2 w-64 bg-white rounded-md shadow-lg border border-gray-200 z-50"
          >
            <div class="py-1">
              <div class="px-4 py-2 text-sm font-medium text-gray-900 border-b border-gray-100">
                Widgets Disponibles
              </div>
              <div
                v-for="widget in availableWidgets"
                :key="widget.id"
                class="flex items-center justify-between px-4 py-2 hover:bg-gray-50"
              >
                <div class="flex items-center">
                  <component :is="widget.component" class="w-5 h-5 text-gray-500 mr-2" />
                  <span class="text-sm text-gray-700">{{ widget.name }}</span>
                </div>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    v-model="widget.enabled"
                    @change="saveWidgetSettings"
                    class="sr-only peer"
                  >
                  <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>
              <div class="border-t border-gray-100 px-4 py-2">
                <button
                  @click="resetWidgetSettings"
                  class="text-xs text-blue-600 hover:text-blue-800"
                >
                  Restablecer por defecto
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="errorMessage" class="bg-red-50 border border-red-200 rounded-md p-4 mb-6">
      <div class="flex">
        <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
        </svg>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error cargando datos</h3>
          <p class="mt-1 text-sm text-red-700">{{ errorMessage }}</p>
          <button @click="refreshData" class="mt-2 btn btn-secondary">
            Reintentar
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading && !hasData" class="flex justify-center items-center py-12">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p class="text-gray-500">Cargando dashboard...</p>
      </div>
    </div>

    <!-- Dashboard Content -->
    <div v-else-if="hasData" class="space-y-6">
      <!-- Stats Cards Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div v-if="isWidgetEnabled('today_revenue')" class="widget-card" :class="{ 'edit-mode': isEditMode }">
          <StatCard
            title="Ingresos de Hoy"
            :value="formatCurrency(statsData.today.revenue)"
            :subtitle="`${statsData.today.sales_count} ventas`"
            icon="currency"
            color="blue"
            :loading="isLoading"
          />
          <div v-if="isEditMode" class="widget-overlay">
            <span class="widget-label">💰 Ingresos de Hoy</span>
          </div>
        </div>

        <div v-if="isWidgetEnabled('monthly_revenue')" class="widget-card" :class="{ 'edit-mode': isEditMode }">
          <StatCard
            title="Este Mes"
            :value="formatCurrency(statsData.this_month.revenue)"
            :subtitle="`${statsData.this_month.sales_count} ventas`"
            icon="trend_up"
            color="green"
            :loading="isLoading"
          />
          <div v-if="isEditMode" class="widget-overlay">
            <span class="widget-label">📈 Ingresos del Mes</span>
          </div>
        </div>

        <div v-if="isWidgetEnabled('average_sale')" class="widget-card" :class="{ 'edit-mode': isEditMode }">
          <StatCard
            title="Venta Promedio"
            :value="formatCurrency(statsData.average_sale)"
            subtitle="Por transacción"
            icon="chart_bar"
            color="yellow"
            :loading="isLoading"
          />
          <div v-if="isEditMode" class="widget-overlay">
            <span class="widget-label">📊 Venta Promedio</span>
          </div>
        </div>

        <div v-if="isWidgetEnabled('inventory_alerts')" class="widget-card" :class="{ 'edit-mode': isEditMode }">
          <StatCard
            title="Alertas de Inventario"
            :value="inventoryAlertsCount.toString()"
            subtitle="Productos necesitan atención"
            icon="warning"
            color="red"
            :loading="isLoading"
          />
          <div v-if="isEditMode" class="widget-overlay">
            <div class="flex items-center widget-label">
              <ExclamationTriangleIcon class="w-5 h-5 text-amber-500 mr-2" />
              <span>Alertas de Inventario</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Payment Methods Section -->
      <div v-if="isWidgetEnabled('payment_methods') && statsData.payment_methods" class="bg-white rounded-lg shadow p-6 widget-card" :class="{ 'edit-mode': isEditMode }">
        <h3 class="text-lg font-medium text-gray-900 mb-6">💳 Estadísticas por Método de Pago</h3>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          <div
            v-for="(stats, method) in paymentMethodsData"
            :key="method"
            class="bg-gray-50 rounded-lg p-4"
          >
            <div class="flex items-center justify-between mb-2">
              <h4 class="text-sm font-medium text-gray-900">{{ stats.display_name }}</h4>
              <span class="text-xs text-gray-500">{{ stats.percentage }}%</span>
            </div>
            <div class="space-y-1">
              <p class="text-lg font-semibold text-gray-900">
                ${{ formatCurrency(stats.revenue) }}
              </p>
              <p class="text-xs text-gray-500">
                {{ stats.count }} ventas • Promedio: ${{ formatCurrency(stats.average_amount) }}
              </p>
            </div>
            <div class="mt-3 bg-gray-200 rounded-full h-2">
              <div
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                :style="{ width: `${Math.max(stats.percentage, 2)}%` }"
              ></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Daily Sales and Inventory Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Daily Sales -->
        <div v-if="isWidgetEnabled('daily_sales')" class="bg-white rounded-lg shadow p-4 widget-card" :class="{ 'edit-mode': isEditMode }">
          <h3 class="text-lg font-medium text-gray-900 mb-3">📅 Ventas por Día</h3>

          <div v-if="statsData.daily_sales && statsData.daily_sales.length" class="space-y-2">
            <div
              v-for="dayData in statsData.daily_sales"
              :key="dayData.date"
              class="flex items-center justify-between p-2 hover:bg-gray-50 rounded-md transition-colors"
            >
              <div class="flex items-center space-x-3">
                <div class="flex-shrink-0">
                  <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                    <span class="text-xs font-bold text-blue-600">{{ formatDayNumber(dayData.date) }}</span>
                  </div>
                </div>
                <div>
                  <h4 class="text-sm font-medium text-gray-900">{{ formatSpanishDate(dayData.date) }}</h4>
                  <p class="text-xs text-gray-500">{{ dayData.sales_count }} ventas</p>
                </div>
              </div>
              <div class="text-right">
                <p class="text-sm font-semibold text-gray-900">
                  ${{ formatCurrency(dayData.total_revenue) }}
                </p>
                <div v-if="dayData.sales && dayData.sales.length > 0" class="text-xs text-gray-500">
                  {{ dayData.sales.length }} transacciones
                </div>
              </div>
            </div>
          </div>

          <div v-else class="text-center py-6 text-gray-500">
            <div class="text-gray-400 mb-2">
              <svg class="w-8 h-8 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
              </svg>
            </div>
            <p class="text-sm">No hay datos de ventas</p>
          </div>
        </div>

        <!-- Inventory Alerts -->
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center mb-4">
            <ExclamationTriangleIcon class="w-6 h-6 text-amber-500 mr-2" />
            <h3 class="text-lg font-medium text-gray-900">Alertas de Inventario</h3>
          </div>

          <div v-if="inventoryAlerts.length" class="space-y-3">
            <div
              v-for="product in inventoryAlerts.slice(0, 5)"
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
                    'bg-yellow-100 text-yellow-800': product.low_stock,
                    'bg-red-100 text-red-800': product.out_of_stock
                  }"
                >
                  {{ product.stock_quantity }} restante
                </span>
              </div>
            </div>
          </div>

          <div v-else class="text-center py-8">
            <svg class="mx-auto h-12 w-12 text-green-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <h3 class="text-sm font-medium text-gray-900">Todo el inventario está bien</h3>
            <p class="text-sm text-gray-500">No hay alertas en este momento.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No hay datos disponibles</h3>
      <p class="mt-1 text-sm text-gray-500">Los datos del dashboard no se pudieron cargar.</p>
      <div class="mt-6">
        <button @click="refreshData" class="btn btn-primary">
          Recargar Datos
        </button>
      </div>
    </div>

    <!-- Edit Mode Indicator -->
    <div v-if="isEditMode" class="edit-mode-indicator">
      <div class="flex items-center">
        <PencilIcon class="w-4 h-4 mr-2" />
        <span>Modo Edición Activo</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useSalesStore } from '../stores/sales'
import { useProductsStore } from '../stores/products'
import {
  ChartBarIcon,
  CurrencyDollarIcon,
  ArrowTrendingUpIcon,
  PresentationChartLineIcon,
  ExclamationTriangleIcon,
  PencilIcon
} from '@heroicons/vue/24/outline'
import StatCard from './widgets/StatCard.vue'

// Stores
const salesStore = useSalesStore()
const productsStore = useProductsStore()

// Local state
const isLoading = ref(false)
const errorMessage = ref<string | null>(null)
const isEditMode = ref(false)
const showWidgetSettings = ref(false)

// Widget configuration
const availableWidgets = ref([
  {
    id: 'today_revenue',
    name: 'Ingresos de Hoy',
    icon: 'currency',
    component: CurrencyDollarIcon,
    enabled: true
  },
  {
    id: 'monthly_revenue',
    name: 'Ingresos del Mes',
    icon: 'trending',
    component: ArrowTrendingUpIcon,
    enabled: true
  },
  {
    id: 'average_sale',
    name: 'Venta Promedio',
    icon: 'chart',
    component: PresentationChartLineIcon,
    enabled: true
  },
  {
    id: 'inventory_alerts',
    name: 'Alertas de Inventario',
    icon: 'warning',
    component: ExclamationTriangleIcon,
    enabled: true
  },
  {
    id: 'payment_methods',
    name: 'Métodos de Pago',
    icon: 'currency',
    component: CurrencyDollarIcon,
    enabled: true
  },
  {
    id: 'daily_sales',
    name: 'Ventas Diarias',
    icon: 'chart',
    component: ChartBarIcon,
    enabled: true
  }
])

// Computed properties
const currentDate = computed(() => {
  return new Date().toLocaleDateString('es-ES', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

const hasData = computed(() => {
  return !!(salesStore.dashboardStats && Object.keys(salesStore.dashboardStats).length > 0)
})

const statsData = computed(() => {
  return salesStore.dashboardStats || {
    today: { revenue: 0, sales_count: 0 },
    this_month: { revenue: 0, sales_count: 0 },
    average_sale: 0,
    payment_methods: null,
    daily_sales: []
  }
})

const paymentMethodsData = computed(() => {
  const paymentMethods = statsData.value.payment_methods
  if (!paymentMethods) return {}

  const { summary, ...methods } = paymentMethods
  return methods
})

const inventoryAlerts = computed(() => [
  ...productsStore.lowStockProducts,
  ...productsStore.outOfStockProducts
])

const inventoryAlertsCount = computed(() => inventoryAlerts.value.length)

// Widget visibility computed properties
const isWidgetEnabled = (widgetId: string) => {
  const widget = availableWidgets.value.find(w => w.id === widgetId)
  return widget ? widget.enabled : false
}

// Methods
function formatCurrency(amount: number): string {
  return amount.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function formatSpanishDate(dateString: string): string {
  if (!dateString) return 'Fecha no disponible'

  try {
    const date = new Date(dateString)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)

    // Check if it's today
    if (date.toDateString() === today.toDateString()) {
      return 'Hoy'
    }

    // Check if it's yesterday
    if (date.toDateString() === yesterday.toDateString()) {
      return 'Ayer'
    }

    // Format in Spanish
    const options: Intl.DateTimeFormatOptions = {
      weekday: 'long',
      day: 'numeric',
      month: 'long'
    }

    const formatter = new Intl.DateTimeFormat('es-ES', options)
    let formatted = formatter.format(date)

    // Capitalize first letter
    formatted = formatted.charAt(0).toUpperCase() + formatted.slice(1)

    return formatted
  } catch (error) {
    console.error('Error formatting date:', error)
    return 'Fecha inválida'
  }
}

function formatDayNumber(dateString: string): string {
  if (!dateString) return '?'

  try {
    const date = new Date(dateString)
    return date.getDate().toString()
  } catch (error) {
    return '?'
  }
}

function saveWidgetSettings() {
  // Save to localStorage
  const settings = availableWidgets.value.map(w => ({
    id: w.id,
    enabled: w.enabled
  }))
  localStorage.setItem('dashboardWidgetSettings', JSON.stringify(settings))

  console.log('Widget settings saved:', settings)
}

function loadWidgetSettings() {
  try {
    const saved = localStorage.getItem('dashboardWidgetSettings')
    if (saved) {
      const settings = JSON.parse(saved)
      settings.forEach((setting: { id: string; enabled: boolean }) => {
        const widget = availableWidgets.value.find(w => w.id === setting.id)
        if (widget) {
          widget.enabled = setting.enabled
        }
      })
      console.log('Widget settings loaded:', settings)
    }
  } catch (error) {
    console.error('Error loading widget settings:', error)
  }
}

function resetWidgetSettings() {
  if (confirm('¿Estás seguro de que quieres restablecer todos los widgets?')) {
    availableWidgets.value.forEach(widget => {
      widget.enabled = true
    })
    saveWidgetSettings()
    showWidgetSettings.value = false
  }
}

// Click outside handler
function handleClickOutside(event: Event) {
  const target = event.target as Element
  if (!target.closest('.relative')) {
    showWidgetSettings.value = false
  }
}

async function refreshData() {
  isLoading.value = true
  errorMessage.value = null

  try {
    console.log('Refreshing dashboard data...')

    await Promise.all([
      salesStore.fetchDashboardStats(),
      productsStore.fetchProducts({ per_page: 100 })
    ])

    console.log('Dashboard data loaded successfully')
    console.log('Sales stats:', salesStore.dashboardStats)
    console.log('Products loaded:', productsStore.products.length)
  } catch (error: any) {
    console.error('Error loading dashboard data:', error)
    errorMessage.value = error.message || 'Error al cargar los datos del dashboard'
  } finally {
    isLoading.value = false
  }
}

// Lifecycle
onMounted(async () => {
  console.log('SimpleDashboard mounted, loading data...')
  loadWidgetSettings()
  await refreshData()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.simple-dashboard {
  min-height: 100vh;
  background-color: #f8fafc;
}

.btn {
  @apply inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2;
}

.btn-primary {
  @apply text-white bg-blue-600 hover:bg-blue-700 focus:ring-blue-500;
}

.btn-secondary {
  @apply text-blue-700 bg-blue-100 hover:bg-blue-200 focus:ring-blue-500;
}

.btn-outline {
  @apply text-gray-700 bg-white border-gray-300 hover:bg-gray-50 focus:ring-blue-500;
}

.btn:disabled {
  @apply opacity-50 cursor-not-allowed;
}

/* Widget editing styles */
.widget-card {
  position: relative;
  transition: all 0.3s ease;
}

.widget-card.edit-mode {
  border: 2px solid #3b82f6;
  border-radius: 8px;
  position: relative;
}

.widget-card.edit-mode:hover {
  box-shadow: 0 10px 25px rgba(59, 130, 246, 0.15);
  transform: translateY(-2px);
}

.widget-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(59, 130, 246, 0.1);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.widget-card.edit-mode:hover .widget-overlay {
  opacity: 1;
}

.widget-label {
  background: rgba(59, 130, 246, 0.9);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

/* Edit mode indicator */
.edit-mode-indicator {
  position: fixed;
  top: 50%;
  right: 20px;
  transform: translateY(-50%);
  background: #3b82f6;
  color: white;
  padding: 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
  z-index: 1000;
}
</style>