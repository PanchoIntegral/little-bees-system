<template>
  <BaseWidget
    :widget-id="widgetId"
    :title="title"
    icon="📅"
    :loading="salesStore.loading"
    :error="salesStore.error"
    :is-edit-mode="isEditMode"
    :is-selected="isSelected"
    @select="$emit('select', $event)"
    @edit="$emit('edit', $event)"
    @remove="$emit('remove', $event)"
  >
    <div v-if="dailySales?.length" class="space-y-4 h-full overflow-y-auto">
      <div
        v-for="dayData in limitedDailySales"
        :key="dayData.date"
        class="border border-gray-200 rounded-lg p-3"
      >
        <!-- Day Header -->
        <div class="flex items-center justify-between mb-2">
          <div>
            <h4 class="text-sm font-semibold text-gray-900">{{ dayData.formatted_date }}</h4>
            <p class="text-xs text-gray-500">{{ dayData.short_date }}</p>
          </div>
          <div class="text-right">
            <p class="text-sm font-medium text-gray-900">
              ${{ formatCurrency(dayData.total_revenue) }}
            </p>
            <p class="text-xs text-gray-500">{{ dayData.sales_count }} ventas</p>
          </div>
        </div>

        <!-- Sales for this day -->
        <div v-if="showDetails && dayData.sales?.length" class="space-y-1 max-h-32 overflow-y-auto">
          <div
            v-for="sale in dayData.sales.slice(0, 3)"
            :key="sale.id"
            class="flex items-center justify-between py-1 px-2 bg-gray-50 rounded-md text-xs"
          >
            <div class="flex-1">
              <p class="font-medium text-gray-900">{{ sale.receipt_number }}</p>
              <p class="text-gray-500 truncate">{{ sale.customer_name }}</p>
            </div>
            <div class="text-right">
              <p class="font-medium text-gray-900">{{ sale.formatted_total }}</p>
              <span
                class="inline-flex items-center px-1 py-0.5 rounded-full text-xs font-medium"
                :class="getStatusClass(sale.status)"
              >
                {{ sale.status_display }}
              </span>
            </div>
          </div>
          <div v-if="dayData.sales.length > 3" class="text-center">
            <p class="text-xs text-gray-400">+ {{ dayData.sales.length - 3 }} más</p>
          </div>
        </div>

        <!-- No sales for this day -->
        <div v-else-if="dayData.sales_count === 0" class="text-center py-2 text-gray-500">
          <p class="text-xs">Sin ventas este día</p>
        </div>
      </div>
    </div>

    <div v-else class="flex items-center justify-center h-full text-gray-500">
      <div class="text-center">
        <svg class="mx-auto h-12 w-12 text-gray-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <p class="text-sm">No hay ventas recientes</p>
      </div>
    </div>
  </BaseWidget>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseWidget from './BaseWidget.vue'
import { useSalesStore } from '../../stores/sales'

interface Props {
  widgetId: string
  title: string
  days?: number
  showDetails?: boolean
  isEditMode?: boolean
  isSelected?: boolean
}

interface Emits {
  select: [widgetId: string]
  edit: [widgetId: string]
  remove: [widgetId: string]
}

const props = withDefaults(defineProps<Props>(), {
  days: 7,
  showDetails: true,
  isEditMode: false,
  isSelected: false
})

const emit = defineEmits<Emits>()

const salesStore = useSalesStore()

const dailySales = computed(() => salesStore.dashboardStats?.daily_sales || [])

const limitedDailySales = computed(() => {
  return dailySales.value.slice(0, props.days)
})

function formatCurrency(amount: number): string {
  return amount.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function getStatusClass(status: string): string {
  const statusClasses = {
    'completed': 'bg-green-100 text-green-800',
    'pending': 'bg-yellow-100 text-yellow-800',
    'cancelled': 'bg-red-100 text-red-800',
    'refunded': 'bg-gray-100 text-gray-800'
  }
  return statusClasses[status as keyof typeof statusClasses] || 'bg-gray-100 text-gray-800'
}
</script>