<template>
  <BaseWidget
    :widget-id="widgetId"
    :title="title"
    icon="warning"
    :loading="productsStore.loading"
    :error="productsStore.error"
    :is-edit-mode="isEditMode"
    :is-selected="isSelected"
    @select="$emit('select', $event)"
    @edit="$emit('edit', $event)"
    @remove="$emit('remove', $event)"
  >
    <div v-if="inventoryAlerts.length" class="space-y-3 h-full overflow-y-auto">
      <div
        v-for="product in limitedAlerts"
        :key="product.id"
        class="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0"
      >
        <div class="flex-1">
          <p class="text-sm font-medium text-gray-900">{{ product.name }}</p>
          <p class="text-xs text-gray-500">SKU: {{ product.sku }}</p>
          <p v-if="product.category" class="text-xs text-gray-400">{{ product.category }}</p>
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
            <ExclamationTriangleIcon v-if="product.out_of_stock || product.low_stock" class="w-3 h-3 ml-1" />
          </span>
          <p class="text-xs text-gray-500 mt-1">
            <span v-if="product.out_of_stock">Sin stock</span>
            <span v-else-if="product.low_stock">Stock bajo</span>
          </p>
        </div>
      </div>

      <!-- Show remaining count -->
      <div v-if="inventoryAlerts.length > limit" class="text-center pt-2 border-t">
        <p class="text-xs text-gray-500">
          + {{ inventoryAlerts.length - limit }} productos más con alertas
        </p>
      </div>
    </div>

    <div v-else class="flex items-center justify-center h-full text-gray-500">
      <div class="text-center">
        <svg class="mx-auto h-12 w-12 text-green-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <h3 class="text-sm font-medium text-gray-900">Todo el inventario está bien</h3>
        <p class="text-sm text-gray-500">No hay alertas de inventario en este momento.</p>
      </div>
    </div>
  </BaseWidget>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
import BaseWidget from './BaseWidget.vue'
import { useProductsStore } from '../../stores/products'

interface Props {
  widgetId: string
  title: string
  limit?: number
  showOutOfStock?: boolean
  showLowStock?: boolean
  isEditMode?: boolean
  isSelected?: boolean
}

interface Emits {
  select: [widgetId: string]
  edit: [widgetId: string]
  remove: [widgetId: string]
}

const props = withDefaults(defineProps<Props>(), {
  limit: 5,
  showOutOfStock: true,
  showLowStock: true,
  isEditMode: false,
  isSelected: false
})

const emit = defineEmits<Emits>()

const productsStore = useProductsStore()

const inventoryAlerts = computed(() => {
  let alerts: any[] = []

  if (props.showOutOfStock) {
    alerts = alerts.concat(productsStore.outOfStockProducts)
  }

  if (props.showLowStock) {
    alerts = alerts.concat(productsStore.lowStockProducts)
  }

  // Sort by stock level (lowest first)
  return alerts.sort((a, b) => a.stock_quantity - b.stock_quantity)
})

const limitedAlerts = computed(() => {
  return inventoryAlerts.value.slice(0, props.limit)
})
</script>