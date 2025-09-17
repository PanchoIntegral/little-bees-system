<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" @click="$emit('close')">
    <div class="relative top-5 mx-auto p-5 border w-[90%] max-w-4xl shadow-lg rounded-md bg-white" @click.stop>
      <div class="mt-3">
        <h3 class="text-lg font-medium text-gray-900 mb-4 flex items-center">
          <svg class="w-6 h-6 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
          </svg>
          Nueva Venta
        </h3>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Left Column: Customer & Product Selection -->
          <div class="space-y-6">
            <!-- Customer Section -->
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="text-sm font-medium text-gray-700 mb-3">Cliente (Opcional)</h4>
              <div class="relative">
                <input
                  v-model="customerName"
                  type="text"
                  placeholder="Nombre del cliente..."
                  class="form-input w-full pl-10"
                  autocomplete="off"
                  :disabled="processing"
                />
                <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                </svg>
              </div>
            </div>

            <!-- Product Search Section -->
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="text-sm font-medium text-gray-700 mb-3">Buscar Productos</h4>
              <div class="relative mb-4">
                <input
                  v-model="productSearch"
                  type="text"
                  placeholder="Buscar productos por nombre..."
                  class="form-input w-full pl-10"
                  autocomplete="off"
                  :disabled="processing"
                  @input="handleProductSearch"
                />
                <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                </svg>
              </div>

              <!-- Product Search Results -->
              <div v-if="filteredProducts.length > 0" class="max-h-60 overflow-y-auto border border-gray-200 rounded-md">
                <div
                  v-for="product in filteredProducts"
                  :key="product.id"
                  class="p-3 hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-b-0"
                  @click="selectProduct(product)"
                >
                  <div class="flex justify-between items-center">
                    <div class="flex-1">
                      <h5 class="font-medium text-gray-900">{{ product.name }}</h5>
                      <p class="text-sm text-gray-500">SKU: {{ product.sku }}</p>
                      <p class="text-sm font-semibold text-green-600">{{ product.formatted_price }}</p>
                    </div>
                    <div class="text-right">
                      <span class="text-xs px-2 py-1 rounded-full"
                            :class="{
                              'bg-green-100 text-green-800': product.in_stock,
                              'bg-red-100 text-red-800': product.out_of_stock,
                              'bg-yellow-100 text-yellow-800': product.low_stock
                            }">
                        Stock: {{ product.stock_quantity }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Payment Method -->
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="text-sm font-medium text-gray-700 mb-3">Método de Pago</h4>
              <select v-model="paymentMethod" class="form-input w-full">
                <option value="cash">Efectivo</option>
                <option value="credit_card">Tarjeta de Crédito</option>
                <option value="debit_card">Tarjeta de Débito</option>
                <option value="digital_wallet">Billetera Digital</option>
              </select>
            </div>

            <!-- Notes -->
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="text-sm font-medium text-gray-700 mb-3">Notas (Opcional)</h4>
              <textarea
                v-model="notes"
                placeholder="Notas adicionales sobre la venta..."
                class="form-input w-full h-20 resize-none"
              ></textarea>
            </div>
          </div>

          <!-- Right Column: Cart & Summary -->
          <div class="space-y-6">
            <!-- Cart Items -->
            <div class="bg-blue-50 p-4 rounded-lg">
              <h4 class="text-sm font-medium text-gray-700 mb-3 flex items-center">
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4m0 0L7 13m0 0l-1.5 4M7 13l-1.5 4m0 0h4m-4 0a2 2 0 104 0m6-4h4m-4 0a2 2 0 104 0"></path>
                </svg>
                Artículos de la Venta ({{ cartItems.length }})
              </h4>
              
              <div v-if="cartItems.length === 0" class="text-center py-8 text-gray-500">
                <svg class="mx-auto h-12 w-12 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                </svg>
                <p>No hay productos en la venta</p>
                <p class="text-sm">Busca y selecciona productos para agregar</p>
              </div>

              <div v-else class="space-y-3 max-h-80 overflow-y-auto">
                <div
                  v-for="(item, index) in cartItems"
                  :key="index"
                  class="bg-white p-3 rounded-md border border-gray-200"
                >
                  <div class="flex justify-between items-start mb-2">
                    <div class="flex-1">
                      <h5 class="font-medium text-gray-900">{{ item.product.name }}</h5>
                      <p class="text-sm text-gray-500">{{ item.product.formatted_price }} c/u</p>
                      <div v-if="item.appliedOffers && item.appliedOffers.length > 0" class="mt-1">
                        <p v-for="offer in item.appliedOffers" :key="offer.id" class="text-xs text-green-600 font-medium">
                          🏷️ {{ offer.name }}
                        </p>
                      </div>
                    </div>
                    <button
                      @click="removeFromCart(index)"
                      class="text-red-600 hover:text-red-800 p-1"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                  
                  <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-2">
                      <button
                        @click="decreaseQuantity(index)"
                        :disabled="item.quantity <= 1"
                        class="btn btn-outline text-sm px-2 py-1 disabled:opacity-50"
                      >
                        -
                      </button>
                      <input
                        v-model.number="item.quantity"
                        type="number"
                        min="1"
                        :max="item.product.stock_quantity"
                        class="form-input w-16 text-center text-sm"
                        @change="updateQuantity(index, item.quantity)"
                      />
                      <button
                        @click="increaseQuantity(index)"
                        :disabled="item.quantity >= item.product.stock_quantity"
                        class="btn btn-outline text-sm px-2 py-1 disabled:opacity-50"
                      >
                        +
                      </button>
                    </div>
                    <div class="font-semibold text-gray-900">
                      ${{ (item.product.price * item.quantity).toFixed(2) }}
                      <div v-if="item.discountAmount && item.discountAmount > 0" class="text-xs text-green-600 mt-1">
                        Descuento: -${{ item.discountAmount.toFixed(2) }}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Sale Summary -->
            <div class="bg-green-50 p-4 rounded-lg">
              <h4 class="text-sm font-medium text-gray-700 mb-3 flex items-center">
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                </svg>
                Precálculo de la Venta
              </h4>


              <!-- Tax Info (Fixed) -->
              <div v-if="cartItems.length > 0" class="mb-4 p-3 bg-gray-100 rounded-md border">
                <h5 class="text-sm font-medium text-gray-700 mb-2 flex items-center">
                  <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                  Impuesto (Automático)
                </h5>
                <div class="flex items-center justify-between">
                  <span class="text-sm text-gray-600">Tasa de impuesto fija:</span>
                  <span class="text-sm font-semibold text-gray-800">8%</span>
                </div>
              </div>

              <!-- Calculation Summary -->
              <div class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-gray-600">Subtotal:</span>
                  <span class="font-medium transition-all duration-300" :class="{ 'text-blue-600 font-bold': subtotalChanged }">${{ subtotal.toFixed(2) }}</span>
                </div>

                <div v-if="totalOfferDiscount > 0" class="flex justify-between text-sm">
                  <span class="text-gray-600">Descuentos (Ofertas):</span>
                  <span class="font-medium text-red-600 transition-all duration-300">-${{ totalOfferDiscount.toFixed(2) }}</span>
                </div>

                <div v-if="taxAmount > 0" class="flex justify-between text-sm">
                  <span class="text-gray-600">Impuesto ({{ taxRate }}%):</span>
                  <span class="font-medium text-orange-600 transition-all duration-300" :class="{ 'text-orange-700 font-bold': taxChanged }">+${{ taxAmount.toFixed(2) }}</span>
                </div>

                <hr class="border-gray-300">
                <div class="flex justify-between text-lg font-bold">
                  <span>Total:</span>
                  <span class="text-green-600 transition-all duration-500" :class="{ 'text-green-700 text-xl': totalChanged }">${{ finalTotal.toFixed(2) }}</span>
                </div>

                <div v-if="cartItems.length > 0" class="pt-3 space-y-2">
                  <div class="text-center text-xs text-green-600 flex items-center justify-center">
                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    Cálculo en tiempo real
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-end space-x-3 mt-6 pt-4 border-t">
          <button
            type="button"
            @click="$emit('close')"
            class="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Cancelar
          </button>
          <button
            type="button"
            @click="processSale"
            :disabled="cartItems.length === 0 || processing"
            class="bg-green-600 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="processing" class="flex items-center">
              <svg class="animate-spin -ml-1 mr-3 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Procesando...
            </span>
            <span v-else>Procesar Venta</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useProductsStore } from '../stores/products'
import { useSalesStore } from '../stores/sales'
import { useOffersStore } from '../stores/offers'
import type { Product } from '../services/products'
import type { CreateSaleData } from '../services/sales'

const emit = defineEmits<{
  close: []
  success: [sale: any]
}>()

// Stores
const productsStore = useProductsStore()
const salesStore = useSalesStore()
const offersStore = useOffersStore()

// Form data
const customerName = ref('')
const productSearch = ref('')
const paymentMethod = ref('cash')
const notes = ref('')
const processing = ref(false)

// Tax configuration
const taxRate = ref(8) // Fixed 8% tax rate

// Visual feedback states
const subtotalChanged = ref(false)
const taxChanged = ref(false)
const totalChanged = ref(false)

// Cart
interface CartItem {
  product: Product
  quantity: number
  appliedOffers?: any[]
  discountAmount?: number
}

const cartItems = ref<CartItem[]>([])

// Product search
const filteredProducts = ref<Product[]>([])

// Computed
const subtotal = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + (item.product.price * item.quantity), 0)
})

// Calculate total offer discounts applied to all items
const totalOfferDiscount = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + (item.discountAmount || 0), 0)
})

const taxableAmount = computed(() => {
  return Math.max(0, subtotal.value - totalOfferDiscount.value)
})

const taxAmount = computed(() => {
  if (taxRate.value <= 0) return 0
  return (taxableAmount.value * taxRate.value) / 100
})

const finalTotal = computed(() => {
  return Math.max(0, subtotal.value - totalOfferDiscount.value + taxAmount.value)
})

// Methods
function handleProductSearch() {
  if (productSearch.value.length < 2) {
    filteredProducts.value = []
    return
  }

  filteredProducts.value = productsStore.products.filter(product =>
    product.active &&
    product.stock_quantity > 0 &&
    (product.name.toLowerCase().includes(productSearch.value.toLowerCase()) ||
     product.sku.toLowerCase().includes(productSearch.value.toLowerCase()))
  ).slice(0, 10) // Limit to 10 results
}

async function selectProduct(product: Product) {
  // Check if product is already in cart
  const existingIndex = cartItems.value.findIndex(item => item.product.id === product.id)

  if (existingIndex !== -1) {
    // Increase quantity if product exists and stock allows
    if (cartItems.value[existingIndex].quantity < product.stock_quantity) {
      cartItems.value[existingIndex].quantity++
      await updateItemOffers(existingIndex)
    }
  } else {
    // Add new product to cart
    const newItem: CartItem = {
      product,
      quantity: 1,
      appliedOffers: [],
      discountAmount: 0
    }
    cartItems.value.push(newItem)
    await updateItemOffers(cartItems.value.length - 1)
  }

  // Clear search
  productSearch.value = ''
  filteredProducts.value = []
}

function removeFromCart(index: number) {
  cartItems.value.splice(index, 1)
}

async function increaseQuantity(index: number) {
  const item = cartItems.value[index]
  if (item.quantity < item.product.stock_quantity) {
    item.quantity++
    await updateItemOffers(index)
  }
}

async function decreaseQuantity(index: number) {
  const item = cartItems.value[index]
  if (item.quantity > 1) {
    item.quantity--
    await updateItemOffers(index)
  }
}

async function updateQuantity(index: number, newQuantity: number) {
  const item = cartItems.value[index]
  if (newQuantity >= 1 && newQuantity <= item.product.stock_quantity) {
    item.quantity = newQuantity
    await updateItemOffers(index)
  } else {
    // Reset to valid value
    item.quantity = Math.max(1, Math.min(newQuantity, item.product.stock_quantity))
    await updateItemOffers(index)
  }
}

// Offer calculation methods
async function updateItemOffers(index: number) {
  const item = cartItems.value[index]
  try {
    const discountData = await offersStore.calculateProductDiscount(
      item.product.id,
      item.quantity,
      item.product.price
    )

    item.discountAmount = discountData.discount_amount
    item.appliedOffers = discountData.applied_offers
  } catch (error) {
    console.error('Error calculating offers for product:', error)
    item.discountAmount = 0
    item.appliedOffers = []
  }
}

function triggerSubtotalAnimation() {
  subtotalChanged.value = true
  setTimeout(() => {
    subtotalChanged.value = false
  }, 1000)
}


function triggerTaxAnimation() {
  taxChanged.value = true
  setTimeout(() => {
    taxChanged.value = false
  }, 1000)
}

function triggerTotalAnimation() {
  totalChanged.value = true
  setTimeout(() => {
    totalChanged.value = false
  }, 1500)
}


async function processSale() {
  if (cartItems.value.length === 0) return
  
  processing.value = true
  
  try {
    // Use anonymous customer name if provided
    let customerId = undefined
    
    // Prepare sale items for the backend
    const saleItemsAttributes = cartItems.value.map(item => ({
      product_id: item.product.id,
      quantity: item.quantity,
      unit_price: item.product.price,
      discount_amount: item.discountAmount || 0,
      applied_offers: item.appliedOffers || []
    }));

    // Create sale with nested items
    const saleData: CreateSaleData = {
      status: 'completed',
      payment_method: paymentMethod.value,
      notes: notes.value || undefined,
      customer_id: customerId,
      anonymous_customer_name: customerName.value.trim() || null,
      sale_items_attributes: saleItemsAttributes
    }
    
    const sale = await salesStore.createSale(saleData)
    
    // Reset form
    cartItems.value = []
    customerName.value = ''
    notes.value = ''

    // Emit success and close
    emit('success', sale)
    emit('close')

  } catch (error) {
    console.error('Error processing sale:', error)
    const errorMessage = error instanceof Error ? error.message : 'Error desconocido'
    alert(`Error al procesar la venta: ${errorMessage}\n\nPor favor, inténtalo de nuevo.`)
  } finally {
    processing.value = false
  }
}

// Watchers for visual feedback
watch(subtotal, () => {
  triggerSubtotalAnimation()
  triggerTotalAnimation()
})

watch(totalOfferDiscount, () => {
  triggerTotalAnimation()
})

watch(taxRate, () => {
  triggerTaxAnimation()
  triggerTotalAnimation()
})

watch(cartItems, () => {
  triggerTotalAnimation()
}, { deep: true })

// Lifecycle
onMounted(async () => {
  // Load products if not already loaded
  if (productsStore.products.length === 0) {
    await productsStore.fetchProducts()
  }
  // Load offers if not already loaded
  if (offersStore.offers.length === 0) {
    await offersStore.fetchOffers()
  }
})
</script>
