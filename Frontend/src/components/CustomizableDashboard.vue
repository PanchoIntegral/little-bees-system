<template>
  <div class="customizable-dashboard">
    <!-- Dashboard Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 flex items-center">
          📊 Dashboard
          <span v-if="isEditMode" class="ml-3 inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
            Modo Edición
          </span>
        </h1>
        <p class="text-sm text-gray-500 mt-1">
          {{ new Date().toLocaleDateString('es-ES', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          }) }}
        </p>
      </div>

      <!-- Dashboard Controls -->
      <div class="flex items-center space-x-3">
        <button
          @click="toggleEditMode"
          class="btn"
          :class="isEditMode ? 'btn-secondary' : 'btn-primary'"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!isEditMode" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
          {{ isEditMode ? 'Guardar' : 'Personalizar' }}
        </button>

        <div class="relative">
          <button
            @click="showSettings = !showSettings"
            class="btn btn-outline"
            :class="{ 'btn-secondary': showSettings }"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
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

    <!-- Loading State -->
    <div v-if="dashboardStore.loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="dashboardStore.error" class="bg-red-50 border border-red-200 rounded-md p-4 mb-6">
      <div class="flex">
        <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
        </svg>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error cargando dashboard</h3>
          <p class="mt-1 text-sm text-red-700">{{ dashboardStore.error }}</p>
          <button @click="loadDashboard" class="mt-2 btn btn-secondary">
            Reintentar
          </button>
        </div>
      </div>
    </div>

    <!-- Dashboard Grid -->
    <div v-else-if="dashboardStore.hasConfig && widgets.length > 0">
      <grid-layout
        :layout="gridLayout"
        :col-num="layout.cols"
        :row-height="30"
        :is-draggable="isEditMode"
        :is-resizable="isEditMode"
        :margin="layout.margin"
        :use-css-transforms="true"
        @layout-updated="onLayoutUpdated"
      >
        <grid-item
          v-for="widget in widgets"
          :key="widget.id"
          :x="widget.position.x"
          :y="widget.position.y"
          :w="widget.position.w"
          :h="widget.position.h"
          :i="widget.id"
          :static="!isEditMode"
          class="grid-item"
          :class="{ 'selected': selectedWidget === widget.id }"
        >
          <!-- Widget Component -->
          <component
            :is="getWidgetComponent(widget.type)"
            :widget-id="widget.id"
            :title="widget.title"
            :data-source="widget.settings.data_source"
            :icon-type="widget.settings.icon"
            :color="widget.settings.color"
            v-bind="widget.settings"
            :is-edit-mode="isEditMode"
            :is-selected="selectedWidget === widget.id"
            @select="selectWidget"
            @edit="editWidget"
            @remove="removeWidget"
          />
        </grid-item>
      </grid-layout>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No hay widgets configurados</h3>
      <p class="mt-1 text-sm text-gray-500">Comienza agregando widgets a tu dashboard.</p>
      <div class="mt-6">
        <button @click="openAddWidgetModal" class="btn btn-primary">
          Agregar Widget
        </button>
      </div>
    </div>

    <!-- Add Widget Modal -->
    <div v-if="showAddWidgetModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" @click="closeAddWidgetModal">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white" @click.stop>
        <h3 class="text-lg font-medium text-gray-900 mb-4">Agregar Widget</h3>

        <div class="space-y-3">
          <div
            v-for="widgetType in availableWidgetTypes"
            :key="widgetType.type"
            @click="addWidget(widgetType)"
            class="p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
          >
            <div class="flex items-center">
              <span class="text-2xl mr-3">{{ widgetType.icon }}</span>
              <div>
                <h4 class="font-medium text-gray-900">{{ widgetType.name }}</h4>
                <p class="text-sm text-gray-500">{{ widgetType.description }}</p>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-6 flex justify-end space-x-3">
          <button @click="closeAddWidgetModal" class="btn btn-outline">
            Cancelar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { GridLayout, GridItem } from 'vue3-grid-layout'
import { useDashboardConfigStore } from '../stores/dashboardConfig'
import { useSalesStore } from '../stores/sales'
import { useProductsStore } from '../stores/products'
import type { Widget } from '../services/dashboardConfig'

// Widget Components
import StatCardWidget from './widgets/StatCardWidget.vue'
import DailyBreakdownWidget from './widgets/DailyBreakdownWidget.vue'
import PaymentStatsWidget from './widgets/PaymentStatsWidget.vue'
import InventoryAlertsWidget from './widgets/InventoryAlertsWidget.vue'

// Stores
const dashboardStore = useDashboardConfigStore()
const salesStore = useSalesStore()
const productsStore = useProductsStore()

// Local state
const selectedWidget = ref<string | null>(null)
const showSettings = ref(false)
const showAddWidgetModal = ref(false)

// Computed
const isEditMode = computed(() => dashboardStore.isEditMode)
const widgets = computed(() => dashboardStore.widgets)
const layout = computed(() => dashboardStore.layout)
const availableWidgetTypes = computed(() => dashboardStore.availableWidgetTypes)

const gridLayout = computed(() => {
  return widgets.value.map(widget => ({
    i: widget.id,
    x: widget.position.x,
    y: widget.position.y,
    w: widget.position.w,
    h: widget.position.h
  }))
})

// Widget component mapping
const widgetComponents = {
  stat_card: StatCardWidget,
  daily_breakdown: DailyBreakdownWidget,
  payment_stats: PaymentStatsWidget,
  inventory_alerts: InventoryAlertsWidget
}

// Methods
function getWidgetComponent(type: string) {
  return widgetComponents[type as keyof typeof widgetComponents] || StatCardWidget
}

// Check dashboard state
console.log('Dashboard loading:', dashboardStore.loading)
console.log('Dashboard hasConfig:', dashboardStore.hasConfig)
console.log('Dashboard widgets count:', widgets.value.length)

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
  // Find available position
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
  switch (type) {
    case 'stat_card':
      return {
        icon: 'chart_bar',
        color: 'blue',
        data_source: 'today_revenue'
      }
    case 'daily_breakdown':
      return {
        days: 7,
        show_details: true
      }
    case 'payment_stats':
      return {
        show_chart: true,
        period: 'month'
      }
    case 'inventory_alerts':
      return {
        limit: 5,
        show_out_of_stock: true,
        show_low_stock: true
      }
    default:
      return {}
  }
}

async function resetToDefault() {
  if (confirm('¿Estás seguro de que quieres restablecer el dashboard a la configuración por defecto?')) {
    try {
      await dashboardStore.resetToDefault()
      showSettings.value = false
    } catch (error) {
      console.error('Error resetting dashboard:', error)
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

async function loadDashboard() {
  await Promise.all([
    dashboardStore.fetchCurrentConfig(),
    salesStore.fetchDashboardStats(),
    productsStore.fetchProducts({ per_page: 100 })
  ])
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
  loadDashboard()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.customizable-dashboard {
  min-height: 100vh;
}

.grid-item {
  transition: all 0.2s ease;
}

.grid-item.selected {
  z-index: 10;
}

.vue-grid-layout {
  background-color: #f8fafc;
  border-radius: 8px;
  padding: 10px;
}

.vue-grid-item {
  touch-action: none;
}

.vue-grid-item.vue-grid-placeholder {
  background: #3b82f6;
  opacity: 0.2;
  transition-duration: 100ms;
  z-index: 2;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  -o-user-select: none;
  user-select: none;
}
</style>