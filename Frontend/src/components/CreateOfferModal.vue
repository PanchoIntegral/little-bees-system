<template>
  <div v-if="show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-4xl mx-4 max-h-[90vh] overflow-y-auto">
      <div class="p-6">
        <!-- Header -->
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold text-gray-900">
            {{ isEditing ? 'Editar Oferta' : 'Nueva Oferta' }}
          </h2>
          <button
            @click="$emit('close')"
            class="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Basic Information -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Nombre de la Oferta *</label>
              <input
                v-model="form.name"
                type="text"
                required
                class="form-input w-full"
                placeholder="Ej: Descuento de Temporada"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de Oferta *</label>
              <select v-model="form.discount_type" required class="form-input w-full" @change="onTypeChange">
                <option value="">Selecciona un tipo</option>
                <option value="percentage">Descuento Porcentual</option>
                <option value="fixed_amount">Descuento Fijo</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Descripción</label>
            <textarea
              v-model="form.description"
              class="form-input w-full h-20 resize-none"
              placeholder="Describe los detalles de la oferta..."
            ></textarea>
          </div>


          <!-- Offer Configuration Based on Type -->
          <div v-if="form.discount_type" class="bg-gray-50 p-6 rounded-lg">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Configuración de la Oferta</h3>

            <!-- Percentage Discount -->
            <div v-if="form.discount_type === 'percentage'" class="space-y-4">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Porcentaje de Descuento *</label>
                  <div class="relative">
                    <input
                      v-model.number="form.discount_percentage"
                      type="number"
                      min="1"
                      max="100"
                      step="0.1"
                      required
                      class="form-input w-full pr-8"
                      placeholder="20"
                    />
                    <span class="absolute right-3 top-3 text-gray-500">%</span>
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Descuento Máximo (Opcional)</label>
                  <div class="relative">
                    <input
                      v-model.number="form.max_discount_amount"
                      type="number"
                      min="0"
                      step="0.01"
                      class="form-input w-full pl-8"
                      placeholder="100.00"
                    />
                    <span class="absolute left-3 top-3 text-gray-500">$</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Fixed Discount -->
            <div v-if="form.discount_type === 'fixed_amount'" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Monto de Descuento *</label>
                <div class="relative">
                  <input
                    v-model.number="form.discount_amount"
                    type="number"
                    min="0.01"
                    step="0.01"
                    required
                    class="form-input w-full pl-8"
                    placeholder="10.00"
                  />
                  <span class="absolute left-3 top-3 text-gray-500">$</span>
                </div>
              </div>
            </div>

          </div>


          <!-- Additional Conditions -->
          <div class="bg-yellow-50 p-6 rounded-lg">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Condiciones Adicionales</h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Compra Mínima *</label>
                <div class="relative">
                  <input
                    v-model.number="form.minimum_purchase"
                    type="number"
                    min="0"
                    step="0.01"
                    required
                    class="form-input w-full pl-8"
                    placeholder="0.00"
                  />
                  <span class="absolute left-3 top-3 text-gray-500">$</span>
                </div>
                <p class="text-xs text-gray-500 mt-1">Monto mínimo de compra para aplicar el descuento</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Límite de Usos</label>
                <input
                  v-model.number="form.usage_limit"
                  type="number"
                  min="1"
                  class="form-input w-full"
                  placeholder="Sin límite"
                />
              </div>
            </div>

            <div class="mt-4">
              <label class="flex items-center">
                <input
                  v-model="form.stackable"
                  type="checkbox"
                  class="form-checkbox h-4 w-4 text-amber-600"
                />
                <span class="ml-2 text-sm text-gray-700">Permitir combinar con otras ofertas</span>
              </label>
            </div>
          </div>

          <!-- Status -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Estado</label>
            <select v-model="form.status" class="form-input w-full">
              <option value="active">Activo</option>
              <option value="inactive">Inactivo</option>
              <option value="scheduled">Programado</option>
            </select>
          </div>

          <!-- Preview -->
          <div v-if="form.discount_type && (form.discount_percentage > 0 || form.discount_amount > 0)" class="bg-green-50 p-6 rounded-lg">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Resumen de la Oferta</h3>
            <div class="space-y-2">
              <div class="flex justify-between">
                <span class="text-gray-700">Tipo de descuento:</span>
                <span class="font-medium">{{ form.discount_type === 'percentage' ? 'Porcentual' : 'Monto fijo' }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-700">Valor del descuento:</span>
                <span class="font-medium text-red-600">
                  {{ form.discount_type === 'percentage' ? `${form.discount_percentage}%` : `$${form.discount_amount}` }}
                </span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-700">Compra mínima:</span>
                <span class="font-medium">${{ form.minimum_purchase || 0 }}</span>
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex justify-end space-x-4 pt-6 border-t">
            <button
              type="button"
              @click="$emit('close')"
              class="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Cancelar
            </button>
            <button
              type="submit"
              :disabled="!isFormValid || processing"
              class="bg-amber-600 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white hover:bg-amber-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="processing" class="flex items-center">
                <svg class="animate-spin -ml-1 mr-3 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Procesando...
              </span>
              <span v-else>{{ isEditing ? 'Actualizar Oferta' : 'Crear Oferta' }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useProductsStore } from '../stores/products'
import type { Product } from '../services/products'

interface Props {
  show: boolean
  offer?: any
}

const props = defineProps<Props>()
const emit = defineEmits<{
  close: []
  success: [offer: any]
}>()

// Stores
const productsStore = useProductsStore()

// Form data - Updated to match backend Discount model
const form = ref({
  name: '',
  description: '',
  discount_type: '', // Maps to backend field
  discount_value: 0, // Maps to backend field
  minimum_amount: 0, // Maps to backend field
  active: true,      // Maps to backend field
  starts_at: '',     // Maps to backend field
  ends_at: '',       // Maps to backend field

  // Legacy fields for UI compatibility
  type: '',
  product: null as Product | null,
  discount_percentage: 0,
  discount_amount: 0,
  start_date: '',
  end_date: ''
})

const processing = ref(false)
const productSearch = ref('')
const showProductDropdown = ref(false)
const filteredProducts = ref<Product[]>([])

// Computed
const isEditing = computed(() => !!props.offer)

const isFormValid = computed(() => {
  return form.value.name &&
         form.value.discount_type &&
         form.value.minimum_purchase >= 0 &&
         isOfferConfigValid()
})

function isOfferConfigValid() {
  switch (form.value.discount_type) {
    case 'percentage':
      return form.value.discount_percentage > 0 && form.value.discount_percentage <= 100
    case 'fixed_amount':
      return form.value.discount_amount > 0
    default:
      return false
  }
}

// Methods
function searchProducts() {
  if (productSearch.value.length < 2) {
    filteredProducts.value = []
    return
  }

  filteredProducts.value = productsStore.products.filter(product =>
    product.active &&
    product.stock_quantity > 0 &&
    (product.name.toLowerCase().includes(productSearch.value.toLowerCase()) ||
     product.sku.toLowerCase().includes(productSearch.value.toLowerCase()))
  ).slice(0, 10)
}

function selectProduct(product: Product) {
  form.value.product = product
  productSearch.value = product.name
  showProductDropdown.value = false
}

function removeProduct() {
  form.value.product = null
  productSearch.value = ''
}

function onTypeChange() {
  // Sync type fields and reset type-specific fields
  form.value.type = form.value.discount_type
  form.value.discount_percentage = 0
  form.value.discount_amount = 0
  form.value.buy_quantity = 2
  form.value.get_quantity = 1
  form.value.bundle_price = 0
  form.value.bundle_quantity = 2
}

function getDiscountPreview() {
  if (!form.value.product) return 'N/A'

  const originalPrice = form.value.product.price

  switch (form.value.type) {
    case 'percentage':
      const percentDiscount = (originalPrice * form.value.discount_percentage) / 100
      const maxDiscount = form.value.max_discount_amount || Infinity
      return `-$${Math.min(percentDiscount, maxDiscount).toFixed(2)} (${form.value.discount_percentage}%)`

    case 'fixed':
      return `-$${Math.min(form.value.discount_amount, originalPrice).toFixed(2)}`

    case 'buy_x_get_y':
      return `${form.value.buy_quantity}x${form.value.get_quantity} (${form.value.get_quantity} gratis)`

    case 'bundle':
      const savings = (originalPrice * form.value.bundle_quantity) - form.value.bundle_price
      return `-$${savings.toFixed(2)} en paquete de ${form.value.bundle_quantity}`

    default:
      return 'N/A'
  }
}

function getFinalPricePreview() {
  if (!form.value.product) return 'N/A'

  const originalPrice = form.value.product.price

  switch (form.value.type) {
    case 'percentage':
      const percentDiscount = (originalPrice * form.value.discount_percentage) / 100
      const maxDiscount = form.value.max_discount_amount || Infinity
      const finalDiscount = Math.min(percentDiscount, maxDiscount)
      return `$${(originalPrice - finalDiscount).toFixed(2)}`

    case 'fixed':
      const fixedDiscount = Math.min(form.value.discount_amount, originalPrice)
      return `$${(originalPrice - fixedDiscount).toFixed(2)}`

    case 'buy_x_get_y':
      return `$${originalPrice.toFixed(2)} c/u (${form.value.get_quantity} gratis)`

    case 'bundle':
      return `$${form.value.bundle_price.toFixed(2)} (paquete de ${form.value.bundle_quantity})`

    default:
      return 'N/A'
  }
}

async function handleSubmit() {
  if (!isFormValid.value) return

  processing.value = true

  try {
    // Map form values to the correct backend fields
    const offerData = {
      name: form.value.name,
      description: form.value.description || '',
      discount_type: form.value.discount_type,
      discount_value: form.value.discount_type === 'percentage'
        ? form.value.discount_percentage
        : form.value.discount_amount,
      minimum_amount: form.value.minimum_purchase || 0,
      starts_at: form.value.start_date || null,
      ends_at: form.value.end_date || null,
      active: form.value.status !== 'inactive'
    }

    emit('success', offerData)
  } catch (error) {
    console.error('Error creating/updating offer:', error)
    alert('Error al procesar la oferta. Inténtalo de nuevo.')
  } finally {
    processing.value = false
  }
}

// Watchers
watch(() => props.offer, (newOffer) => {
  if (newOffer) {
    // Populate form with existing offer data
    Object.assign(form.value, newOffer)
    if (newOffer.product) {
      productSearch.value = newOffer.product.name
    }
  } else {
    // Reset form for new offer
    Object.assign(form.value, {
      name: '',
      description: '',
      discount_type: '',
      type: '',
      product: null,
      discount_percentage: 0,
      discount_amount: 0,
      max_discount_amount: 0,
      buy_quantity: 2,
      get_quantity: 1,
      bundle_price: 0,
      bundle_quantity: 2,
      start_date: '',
      end_date: '',
      minimum_purchase: 0,
      usage_limit: 0,
      limit_per_customer: 0,
      stackable: false,
      status: 'active'
    })
    productSearch.value = ''
  }
}, { immediate: true })

// Close dropdown when clicking outside
watch(showProductDropdown, (show) => {
  if (show) {
    document.addEventListener('click', closeDropdown)
  } else {
    document.removeEventListener('click', closeDropdown)
  }
})

function closeDropdown(event: Event) {
  const target = event.target as HTMLElement
  if (!target.closest('.relative')) {
    showProductDropdown.value = false
  }
}

// Lifecycle
onMounted(async () => {
  if (productsStore.products.length === 0) {
    await productsStore.fetchProducts()
  }
})
</script>