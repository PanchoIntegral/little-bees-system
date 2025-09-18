<template>
  <div class="unified-dashboard p-6 min-h-screen bg-gray-50">
    <!-- Dashboard Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 flex items-center">
          📊 Dashboard
          <span v-if="isCustomizable && isEditMode" class="ml-3 inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
            Modo Edición
          </span>
        </h1>
        <p class="text-sm text-gray-500 mt-1">
          {{ currentDate }}
        </p>
      </div>

      <!-- Dashboard Controls -->
      <div class="flex items-center space-x-3">
        <button
          @click="refreshData"
          :disabled="isLoading"
          class="btn btn-outline"
        >
          <svg v-if="!isLoading" class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
          </svg>
          <div v-else class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600 mr-2"></div>
          {{ isLoading ? 'Actualizando...' : 'Actualizar' }}
        </button>

        <button
          @click="toggleCustomizable"
          class="btn"
          :class="isCustomizable ? 'btn-secondary' : 'btn-primary'"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
          </svg>
          {{ isCustomizable ? 'Vista Simple' : 'Personalizar' }}
        </button>

        <!-- Edit Mode Controls (only when customizable) -->
        <div v-if="isCustomizable" class="flex items-center space-x-3">
          <button
            @click="toggleEditMode"
            class="btn"
            :class="isEditMode ? 'btn-secondary' : 'btn-primary'"
          >
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path v-if="!isEditMode" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
              <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            {{ isEditMode ? 'Guardar' : 'Editar' }}
          </button>

          <div class="relative">
            <button
              @click="showSettings = !showSettings"
              class="btn btn-outline"
              :class="{ 'btn-secondary': showSettings }"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4"></path>
              </svg>
            </button>

            <!-- Settings Dropdown -->
            <div
              v-if="showSettings"
              class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg border border-gray-200 z-50"
            >
              <div class="py-1">
                <button
                  @click="openAddWidgetModal"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  ➕ Agregar Widget
                </button>
                <button
                  @click="resetToDefault"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  🔄 Restablecer por defecto
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
    <div v-else-if="hasData">
      <!-- Simple Dashboard View -->
      <div v-if="!isCustomizable">
        <SimpleDashboardContent
          :stats-data="statsData"
          :inventory-alerts="inventoryAlerts"
          :is-loading="isLoading"
        />
      </div>

      <!-- Customizable Dashboard View -->
      <div v-else>
        <CustomizableDashboardContent
          :widgets="widgets"
          :layout="layout"
          :is-edit-mode="isEditMode"
          :selected-widget="selectedWidget"
          @layout-updated="onLayoutUpdated"
          @select-widget="selectWidget"
          @edit-widget="editWidget"
          @remove-widget="removeWidget"
        />
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

    <!-- Add Widget Modal -->
    <AddWidgetModal
      v-if="showAddWidgetModal"
      :available-widget-types="availableWidgetTypes"
      @add-widget="addWidget"
      @close="closeAddWidgetModal"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useDashboardConfigStore } from '../stores/dashboardConfig'
import { useSalesStore } from '../stores/sales'
import { useProductsStore } from '../stores/products'
import { useWidgetRegistry } from '../composables/useWidgetRegistry'
import type { Widget } from '../services/dashboardConfig'

// Components
import SimpleDashboardContent from './dashboard/SimpleDashboardContent.vue'
import CustomizableDashboardContent from './dashboard/CustomizableDashboardContent.vue'
import AddWidgetModal from './dashboard/AddWidgetModal.vue'

// Stores
const dashboardStore = useDashboardConfigStore()
const salesStore = useSalesStore()
const productsStore = useProductsStore()

// Local state
const isCustomizable = ref(false)
const selectedWidget = ref<string | null>(null)
const showSettings = ref(false)
const showAddWidgetModal = ref(false)
const errorMessage = ref<string | null>(null)

// Computed properties
const currentDate = computed(() => {
  return new Date().toLocaleDateString('es-ES', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

const isEditMode = computed(() => dashboardStore.isEditMode)
const widgets = computed(() => dashboardStore.widgets)
const layout = computed(() => dashboardStore.layout)
const availableWidgetTypes = computed(() => dashboardStore.availableWidgetTypes)

const isLoading = computed(() => {
  return dashboardStore.loading || salesStore.loading || productsStore.loading
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

const inventoryAlerts = computed(() => [
  ...productsStore.lowStockProducts,
  ...productsStore.outOfStockProducts
])

// Methods
function toggleCustomizable() {
  isCustomizable.value = !isCustomizable.value
  if (isCustomizable.value) {
    loadDashboardConfig()
  }
}

function toggleEditMode() {
  if (isEditMode.value) {
    dashboardStore.saveCurrentConfig()
  }
  dashboardStore.toggleEditMode()
  selectedWidget.value = null
}

function selectWidget(widgetId: string) {
  selectedWidget.value = selectedWidget.value === widgetId ? null : widgetId
}

function editWidget(widgetId: string) {
  console.log('Edit widget:', widgetId)
  // TODO: Implement widget edit modal
}

async function removeWidget(widgetId: string) {
  if (confirm('¿Estás seguro de que quieres eliminar este widget?')) {
    try {
      await dashboardStore.removeWidget(widgetId)
    } catch (error) {
      console.error('Error removing widget:', error)
      errorMessage.value = 'Error eliminando widget'
    }
  }
}

function openAddWidgetModal() {
  showAddWidgetModal.value = true
  showSettings.value = false
}

function closeAddWidgetModal() {
  showAddWidgetModal.value = false
}

function addWidget(widgetType: any) {
  const newWidget: Widget = {
    id: `widget_${Date.now()}`,
    type: widgetType.type,
    title: widgetType.name,
    position: {
      x: 0,
      y: 0,
      w: widgetType.defaultSize.w,
      h: widgetType.defaultSize.h
    },
    settings: getDefaultSettings(widgetType.type)
  }

  dashboardStore.addWidgetLocal(newWidget)
  closeAddWidgetModal()
}

function getDefaultSettings(type: string) {
  const { getDefaultSettings: getWidgetDefaultSettings } = useWidgetRegistry()
  return getWidgetDefaultSettings(type)
}

async function resetToDefault() {
  if (confirm('¿Estás seguro de que quieres restablecer el dashboard a la configuración por defecto?')) {
    try {
      await dashboardStore.resetToDefault()
      showSettings.value = false
    } catch (error) {
      console.error('Error resetting dashboard:', error)
      errorMessage.value = 'Error restableciendo configuración'
    }
  }
}

function onLayoutUpdated(newLayout: any[]) {
  newLayout.forEach(item => {
    dashboardStore.updateWidgetLocal(item.i, {
      position: {
        x: item.x,
        y: item.y,
        w: item.w,
        h: item.h
      }
    })
  })
}

async function refreshData() {
  errorMessage.value = null

  try {
    await Promise.all([
      salesStore.fetchDashboardStats(),
      productsStore.fetchProducts({ per_page: 100 })
    ])

    if (isCustomizable.value) {
      await loadDashboardConfig()
    }
  } catch (error: any) {
    console.error('Error loading dashboard data:', error)
    errorMessage.value = error.message || 'Error al cargar los datos del dashboard'
  }
}

async function loadDashboardConfig() {
  try {
    await dashboardStore.fetchCurrentConfig()
  } catch (error: any) {
    console.error('Error loading dashboard config:', error)
    // Fallback to simple dashboard if config fails
    errorMessage.value = 'Error cargando configuración personalizada'
  }
}

// Click outside handler
function handleClickOutside(event: Event) {
  const target = event.target as Element
  if (!target.closest('.relative')) {
    showSettings.value = false
  }
}

// Lifecycle
onMounted(() => {
  refreshData()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.unified-dashboard {
  min-height: 100vh;
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
</style>