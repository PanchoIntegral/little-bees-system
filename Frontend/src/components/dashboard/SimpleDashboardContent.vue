<template>
  <div class="space-y-6">
    <!-- Stats Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <StatCard
        title="Ingresos de Hoy"
        :value="formatCurrency(statsData.today.revenue)"
        :subtitle="`${statsData.today.sales_count} ventas`"
        icon="currency"
        color="blue"
        :loading="isLoading"
      />

      <StatCard
        title="Este Mes"
        :value="formatCurrency(statsData.this_month.revenue)"
        :subtitle="`${statsData.this_month.sales_count} ventas`"
        icon="trend_up"
        color="green"
        :loading="isLoading"
      />

      <StatCard
        title="Venta Promedio"
        :value="formatCurrency(statsData.average_sale)"
        subtitle="Por transacción"
        icon="chart_bar"
        color="yellow"
        :loading="isLoading"
      />

      <StatCard
        title="Alertas de Inventario"
        :value="inventoryAlertsCount.toString()"
        subtitle="Productos necesitan atención"
        icon="warning"
        color="red"
        :loading="isLoading"
      />
    </div>

    <!-- Payment Methods Section -->
    <div v-if="statsData.payment_methods" class="bg-white rounded-lg shadow p-6">
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
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">📅 Ventas por Día</h3>

        <div v-if="statsData.daily_sales && statsData.daily_sales.length" class="space-y-4">
          <div
            v-for="dayData in statsData.daily_sales"
            :key="dayData.date"
            class="border border-gray-200 rounded-lg p-4"
          >
            <div class="flex items-center justify-between mb-3">
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

            <div v-if="dayData.sales && dayData.sales.length" class="space-y-2 max-h-32 overflow-y-auto">
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
                </div>
              </div>
            </div>

            <div v-else class="text-center py-2 text-gray-500">
              <p class="text-xs">Sin ventas este día</p>
            </div>
          </div>
        </div>

        <div v-else class="text-center py-8 text-gray-500">
          <p>No hay datos de ventas disponibles</p>
        </div>
      </div>

      <!-- Inventory Alerts -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">⚠️ Alertas de Inventario</h3>

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
</template>

<script setup lang="ts">
import { computed } from 'vue'
import StatCard from '../widgets/StatCard.vue'

interface Props {
  statsData: any
  inventoryAlerts: any[]
  isLoading: boolean
}

const props = defineProps<Props>()

const inventoryAlertsCount = computed(() => props.inventoryAlerts.length)

const paymentMethodsData = computed(() => {
  const paymentMethods = props.statsData.payment_methods
  if (!paymentMethods) return {}

  const { summary, ...methods } = paymentMethods
  return methods
})

function formatCurrency(amount: number): string {
  return amount.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}
</script>