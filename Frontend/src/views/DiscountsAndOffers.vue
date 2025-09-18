<template>
  <div class="max-w-7xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div class="flex items-center">
          <div class="w-12 h-12 bg-gradient-to-r from-amber-500 to-orange-500 rounded-xl flex items-center justify-center mr-4">
            <TagIcon class="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 class="text-3xl font-bold text-gray-900">Descuentos y Ofertas</h1>
            <p class="text-gray-600 text-sm mt-1">Gestiona ofertas especiales y descuentos para tus productos</p>
          </div>
        </div>
        <button
          @click="showCreateOfferModal = true"
          class="btn btn-amber"
        >
          <PlusIcon class="w-5 h-5 mr-2" />
          Nueva Oferta
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <!-- Active Offers -->
      <div class="card-elevated">
        <div class="flex items-start justify-between">
          <div class="flex-shrink-0">
            <div class="w-12 h-12 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl flex items-center justify-center">
              <TagIcon class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <p class="text-sm font-medium text-gray-600 mb-1">Ofertas Activas</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            {{ activeOffers }}
          </p>
          <p class="text-sm text-gray-500 mt-1">Actualmente ejecutándose</p>
        </div>
      </div>


      <!-- Total Savings -->
      <div class="card-elevated">
        <div class="flex items-start justify-between">
          <div class="flex-shrink-0">
            <div class="w-12 h-12 bg-gradient-to-r from-purple-500 to-purple-600 rounded-xl flex items-center justify-center">
              <ArrowTrendingUpIcon class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <p class="text-sm font-medium text-gray-600 mb-1">Ahorros Totales</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            ${{ totalSavings.toFixed(2) }}
          </p>
          <p class="text-sm text-gray-500 mt-1">Ahorros del cliente</p>
        </div>
      </div>

      <!-- Average Discount -->
      <div class="card-elevated">
        <div class="flex items-start justify-between">
          <div class="flex-shrink-0">
            <div class="w-12 h-12 bg-gradient-to-r from-orange-500 to-red-500 rounded-xl flex items-center justify-center">
              <CurrencyDollarIcon class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <p class="text-sm font-medium text-gray-600 mb-1">Descuento Promedio</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            {{ averageDiscount.toFixed(1) }}%
          </p>
          <p class="text-sm text-gray-500 mt-1">Por oferta</p>
        </div>
      </div>
    </div>

    <!-- Filters and Search -->
    <div class="card-elevated">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-gray-900 flex items-center">
          <FunnelIcon class="w-5 h-5 text-gray-500 mr-2" />
          Filtros y Búsqueda
        </h3>
        <span class="text-sm text-gray-500">{{ filteredOffers.length }} ofertas encontradas</span>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="form-group">
          <label class="form-label">Buscar Ofertas</label>
          <div class="relative">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Buscar por nombre o producto..."
              class="form-input w-full pl-10"
            />
            <MagnifyingGlassIcon class="w-5 h-5 text-gray-400 absolute left-3 top-3" />
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Offer Type</label>
          <select v-model="selectedOfferType" class="form-input w-full">
            <option value="">All Types</option>
            <option value="percentage">Percentage Discount</option>
            <option value="fixed">Fixed Amount</option>
            <option value="buy_x_get_y">Buy X Get Y</option>
            <option value="bundle">Bundle Deal</option>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label">Status</label>
          <select v-model="selectedStatus" class="form-input w-full">
            <option value="">All Status</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="scheduled">Scheduled</option>
            <option value="expired">Expired</option>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label invisible">Actions</label>
          <button
            @click="clearFilters"
            class="btn btn-outline w-full"
          >
            <ArrowPathIcon class="w-4 h-4 mr-2" />
            Clear Filters
          </button>
        </div>
      </div>
    </div>

    <!-- Offers List -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200">
      <div class="p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Lista de Ofertas</h3>

        <!-- Loading State -->
        <div v-if="offersStore.loading" class="text-center py-12">
          <svg class="animate-spin h-8 w-8 text-amber-500 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <p class="text-gray-500">Cargando ofertas...</p>
        </div>

        <div v-else-if="filteredOffers.length === 0" class="text-center py-12">
          <svg class="mx-auto h-12 w-12 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
          </svg>
          <h3 class="text-lg font-medium text-gray-900 mb-2">No hay ofertas</h3>
          <p class="text-gray-500 mb-4">Comienza creando tu primera oferta o descuento.</p>
          <button
            @click="showCreateOfferModal = true"
            class="btn btn-amber"
          >
            <PlusIcon class="w-4 h-4 mr-2" />
            Create First Offer
          </button>
        </div>

        <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div
            v-for="offer in filteredOffers"
            :key="offer.id"
            class="card-elevated group"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <div class="flex items-center mb-2">
                  <h4 class="text-lg font-semibold text-gray-900">{{ offer.name }}</h4>
                  <span
                    class="ml-3"
                    :class="{
                      'status-active': offer.status === 'active',
                      'status-inactive': offer.status === 'inactive',
                      'status-warning': offer.status === 'scheduled',
                      'status-danger': offer.status === 'expired'
                    }"
                  >
                    {{ getStatusLabel(offer.status) }}
                  </span>
                  <span
                    class="ml-2 px-3 py-1.5 rounded-full text-xs font-semibold shadow-soft"
                    :class="{
                      'bg-purple-100 text-purple-800': offer.type === 'percentage',
                      'bg-blue-100 text-blue-800': offer.type === 'fixed',
                      'bg-orange-100 text-orange-800': offer.type === 'buy_x_get_y',
                      'bg-pink-100 text-pink-800': offer.type === 'bundle'
                    }"
                  >
                    {{ getTypeLabel(offer.type) }}
                  </span>
                </div>

                <p class="text-gray-600 mb-3">{{ offer.description }}</p>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                  <div>
                    <span class="font-medium text-gray-700">Producto:</span>
                    <span class="text-gray-600 ml-1">{{ offer.product?.name || 'N/A' }}</span>
                  </div>
                  <div>
                    <span class="font-medium text-gray-700">Descuento:</span>
                    <span class="text-gray-600 ml-1">{{ formatDiscount(offer) }}</span>
                  </div>
                  <div>
                    <span class="font-medium text-gray-700">Vigencia:</span>
                    <span class="text-gray-600 ml-1">{{ formatDateRange(offer) }}</span>
                  </div>
                </div>
              </div>

              <div class="flex items-center space-x-2 ml-4">
                <button
                  @click="editOffer(offer)"
                  class="bg-blue-100 hover:bg-blue-200 text-blue-700 p-2 rounded-lg transition-colors"
                  title="Editar oferta"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                  </svg>
                </button>

                <button
                  @click="toggleOfferStatus(offer)"
                  class="p-2 rounded-lg transition-colors"
                  :class="offer.status === 'active' ? 'bg-red-100 hover:bg-red-200 text-red-700' : 'bg-green-100 hover:bg-green-200 text-green-700'"
                  :title="offer.status === 'active' ? 'Desactivar oferta' : 'Activar oferta'"
                >
                  <svg v-if="offer.status === 'active'" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1m4 0h1m-6 4h.01M19 10a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </button>

                <button
                  @click="deleteOffer(offer)"
                  class="bg-red-100 hover:bg-red-200 text-red-700 p-2 rounded-lg transition-colors"
                  title="Eliminar oferta"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create Offer Modal -->
    <SimpleOfferModal
      v-if="showCreateOfferModal"
      @close="closeOfferModal"
      @success="handleOfferSuccess"
    />

    <!-- Edit Offer Modal -->
    <CreateOfferModal
      v-if="showEditOfferModal"
      :show="showEditOfferModal"
      :offer="selectedOffer"
      @success="handleOfferEditSuccess"
      @close="closeOfferModal"
    />

    <!-- Toast Container -->
    <ToastContainer />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  TagIcon,
  PlusIcon,
  CubeIcon,
  ArrowTrendingUpIcon,
  CurrencyDollarIcon,
  FunnelIcon,
  MagnifyingGlassIcon,
  ArrowPathIcon
} from '@heroicons/vue/24/outline'
import { useProductsStore } from '../stores/products'
import { useOffersStore } from '../stores/offers'
import { useToast } from '../services/toast'
import SimpleOfferModal from '../components/SimpleOfferModal.vue'
import CreateOfferModal from '../components/CreateOfferModal.vue'
import ToastContainer from '../components/ToastContainer.vue'

// Stores
const productsStore = useProductsStore()
const offersStore = useOffersStore()
const toast = useToast()

// Reactive data
const searchQuery = ref('')
const selectedOfferType = ref('')
const selectedStatus = ref('')
const showCreateOfferModal = ref(false)
const showEditOfferModal = ref(false)
const selectedOffer = ref(null)

// Computed properties
const filteredOffers = computed(() => {
  return offersStore.offers.filter(offer => {
    const matchesSearch = !searchQuery.value ||
      offer.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      offer.product?.name.toLowerCase().includes(searchQuery.value.toLowerCase())

    const matchesType = !selectedOfferType.value || offer.type === selectedOfferType.value
    const matchesStatus = !selectedStatus.value || offer.status === selectedStatus.value

    return matchesSearch && matchesType && matchesStatus
  })
})

// Use real statistics from the store
const activeOffers = computed(() => offersStore.offerStats.active_offers)
const productsWithOffers = computed(() => offersStore.offerStats.products_with_offers)
const totalSavings = computed(() => {
  // Calculate real savings based on actual offers
  let savings = 0
  offersStore.offers.forEach(offer => {
    if (offer.status === 'active' && offer.product) {
      const basePrice = offer.product.price
      switch (offer.type) {
        case 'percentage':
          if (offer.discount_percentage) {
            const discount = (basePrice * offer.discount_percentage) / 100
            const maxDiscount = offer.max_discount_amount || discount
            savings += Math.min(discount, maxDiscount)
          }
          break
        case 'fixed':
          if (offer.discount_amount) {
            savings += Math.min(offer.discount_amount, basePrice)
          }
          break
        case 'buy_x_get_y':
          if (offer.buy_quantity && offer.get_quantity) {
            // Estimate savings for buy X get Y offers
            savings += (basePrice * offer.get_quantity)
          }
          break
        case 'bundle':
          if (offer.bundle_price && offer.bundle_quantity) {
            const originalCost = basePrice * offer.bundle_quantity
            savings += Math.max(0, originalCost - offer.bundle_price)
          }
          break
      }
    }
  })
  return savings
})

const averageDiscount = computed(() => offersStore.offerStats.average_discount)

// Methods
function clearFilters() {
  searchQuery.value = ''
  selectedOfferType.value = ''
  selectedStatus.value = ''
}

async function editOffer(offer: any) {
  selectedOffer.value = offer
  showEditOfferModal.value = true
}

async function toggleOfferStatus(offer: any) {
  try {
    console.log('Toggling offer:', offer.id, offer)
    await offersStore.toggleOfferStatus(offer.id)
    console.log('Toggle successful')
    // Refresh offers to get updated state
    await offersStore.fetchOffers()

    // Show success message
    const statusText = offer.active ? 'desactivada' : 'activada'
    toast.show(`Oferta ${statusText} exitosamente`, 'success')
  } catch (error) {
    console.error('Error toggling offer status:', error)
    toast.show(`Error al cambiar el estado de la oferta: ${error.message}`, 'error')
  }
}

async function deleteOffer(offer: any) {
  if (confirm('¿Estás seguro de que quieres eliminar esta oferta?')) {
    try {
      await offersStore.deleteOffer(offer.id)
      toast.show('Oferta eliminada exitosamente', 'success')
    } catch (error) {
      console.error('Error deleting offer:', error)
      toast.show('Error al eliminar la oferta', 'error')
    }
  }
}

function closeOfferModal() {
  showCreateOfferModal.value = false
  showEditOfferModal.value = false
  selectedOffer.value = null
}

async function handleOfferSuccess(offerData: any) {
  try {
    console.log('🎉 Nueva oferta creada exitosamente:', offerData)
    // Since SimpleOfferModal only creates new offers, we don't need to check for updates
    await offersStore.fetchOffers() // Refresh the offers list to show the new offer
    closeOfferModal()
    toast.show('Oferta creada exitosamente', 'success')
  } catch (error) {
    console.error('Error saving offer:', error)
    toast.show('Error al guardar la oferta', 'error')
  }
}

async function handleOfferEditSuccess(offerData: any) {
  try {
    console.log('🎉 Oferta editada exitosamente:', offerData)

    if (selectedOffer.value && selectedOffer.value.id) {
      // Update existing offer
      await offersStore.updateOffer(selectedOffer.value.id, offerData)
    }

    await offersStore.fetchOffers() // Refresh the offers list
    closeOfferModal()
    toast.show('Oferta actualizada exitosamente', 'success')
  } catch (error) {
    console.error('Error updating offer:', error)
    toast.show('Error al actualizar la oferta', 'error')
  }
}

function getStatusLabel(status: string) {
  const labels = {
    active: 'Activo',
    inactive: 'Inactivo',
    scheduled: 'Programado',
    expired: 'Expirado'
  }
  return labels[status] || status
}

function getTypeLabel(type: string) {
  const labels = {
    percentage: 'Porcentual',
    fixed: 'Fijo',
    buy_x_get_y: 'X por Y',
    bundle: 'Paquete'
  }
  return labels[type] || type
}

function formatDiscount(offer: any) {
  if (offer.type === 'percentage') {
    return `${offer.discount_percentage}%`
  } else if (offer.type === 'fixed') {
    return `$${offer.discount_amount}`
  } else if (offer.type === 'buy_x_get_y') {
    return `${offer.buy_quantity}x${offer.get_quantity}`
  }
  return 'N/A'
}

function formatDateRange(offer: any) {
  if (offer.start_date && offer.end_date) {
    return `${offer.start_date} - ${offer.end_date}`
  }
  return 'Sin fecha'
}

// Lifecycle
onMounted(async () => {
  if (productsStore.products.length === 0) {
    await productsStore.fetchProducts()
  }
  // Load offers when component mounts
  await offersStore.fetchOffers()
})
</script>