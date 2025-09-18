<template>
  <BaseWidget
    :widget-id="widgetId"
    :title="title"
    icon="💳"
    :loading="salesStore.loading"
    :error="salesStore.error"
    :is-edit-mode="isEditMode"
    :is-selected="isSelected"
    @select="$emit('select', $event)"
    @edit="$emit('edit', $event)"
    @remove="$emit('remove', $event)"
  >
    <div v-if="paymentMethodsData && Object.keys(paymentMethodsData).length" class="h-full">
      <!-- Payment Methods Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-4">
        <div
          v-for="(stats, method) in paymentMethodsData"
          :key="method"
          class="bg-gray-50 rounded-lg p-3"
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
          <!-- Progress bar -->
          <div class="mt-2 bg-gray-200 rounded-full h-1.5">
            <div
              class="bg-blue-600 h-1.5 rounded-full transition-all duration-300"
              :style="{ width: `${Math.max(stats.percentage, 2)}%` }"
            ></div>
          </div>
        </div>
      </div>

      <!-- Summary Statistics -->
      <div v-if="summaryData" class="border-t pt-3">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 text-center">
          <div class="bg-blue-50 rounded-lg p-2">
            <h4 class="text-xs font-medium text-blue-900">Total de Ventas</h4>
            <p class="text-lg font-bold text-blue-600">
              {{ summaryData.total_sales }}
            </p>
          </div>
          <div class="bg-green-50 rounded-lg p-2">
            <h4 class="text-xs font-medium text-green-900">Método Más Usado</h4>
            <p class="text-sm font-semibold text-green-600">
              {{ getPaymentMethodDisplayName(summaryData.most_used_method) }}
            </p>
          </div>
          <div class="bg-purple-50 rounded-lg p-2">
            <h4 class="text-xs font-medium text-purple-900">Mayor Ingresos</h4>
            <p class="text-sm font-semibold text-purple-600">
              {{ getPaymentMethodDisplayName(summaryData.highest_revenue_method) }}
            </p>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="flex items-center justify-center h-full text-gray-500">
      <div class="text-center">
        <svg class="mx-auto h-12 w-12 text-gray-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
        </svg>
        <p class="text-sm">No hay datos de métodos de pago</p>
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
  period?: 'month' | 'week' | 'today'
  showChart?: boolean
  isEditMode?: boolean
  isSelected?: boolean
}

interface Emits {
  select: [widgetId: string]
  edit: [widgetId: string]
  remove: [widgetId: string]
}

const props = withDefaults(defineProps<Props>(), {
  period: 'month',
  showChart: true,
  isEditMode: false,
  isSelected: false
})

const emit = defineEmits<Emits>()

const salesStore = useSalesStore()

const paymentMethodsData = computed(() => {
  const paymentMethods = salesStore.dashboardStats?.payment_methods
  if (!paymentMethods) return {}

  // Filter out the summary object and return only payment method data
  const { summary, ...methods } = paymentMethods
  return methods
})

const summaryData = computed(() => {
  return salesStore.dashboardStats?.payment_methods?.summary
})

function formatCurrency(amount: number): string {
  return amount.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function getPaymentMethodDisplayName(method: string): string {
  const displayNames: Record<string, string> = {
    'cash': 'Efectivo',
    'credit_card': 'Tarjeta de Crédito',
    'debit_card': 'Tarjeta de Débito',
    'digital_wallet': 'Billetera Digital'
  }
  return displayNames[method] || method
}
</script>