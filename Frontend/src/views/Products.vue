<template>
  <div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div class="flex items-center">
        <CubeIcon class="w-8 h-8 text-amber-500 mr-3" />
        <h1 class="text-3xl font-bold text-gray-900">Productos</h1>
      </div>
      <div class="flex flex-col sm:flex-row gap-3">
        <div class="relative">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar productos..."
            class="form-input pl-10 pr-4 py-2 w-full sm:w-80"
            @input="handleSearch"
          />
          <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
        </div>
        <button
          @click="showCreateModal = true"
          class="btn btn-primary"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          Agregar Producto
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div class="card">
      <div class="flex flex-wrap gap-4 items-center">
        <span class="text-sm font-medium text-gray-700">Filtrar por:</span>
        <select
          v-model="selectedCategory"
          @change="handleFilterChange"
          class="form-input w-auto"
        >
          <option value="">Todas las Categorías</option>
          <option
            v-for="category in productsStore.categories"
            :key="category"
            :value="category"
          >
            {{ category }}
          </option>
        </select>
        <select
          v-model="selectedStockStatus"
          @change="handleFilterChange"
          class="form-input w-auto"
        >
          <option value="">All Stock Levels</option>
          <option value="in_stock">In Stock</option>
          <option value="low_stock">Low Stock</option>
          <option value="out_of_stock">Out of Stock</option>
        </select>
        <button
          @click="resetFilters"
          class="btn btn-outline"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
          </svg>
          Reset
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="productsStore.loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
    </div>

    <!-- Error State -->
    <div v-if="productsStore.error" class="bg-red-50 border border-red-200 rounded-md p-4">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error loading products</h3>
          <div class="mt-2 text-sm text-red-700">
            <p>{{ productsStore.error }}</p>
          </div>
          <div class="mt-4">
            <button
              @click="loadProducts"
              class="btn btn-secondary"
            >
              Try again
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="!productsStore.loading && productsStore.products.length === 0" class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No products found</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new product.</p>
      <div class="mt-6">
        <button
          @click="showCreateModal = true"
          class="btn btn-primary"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          Agregar Producto
        </button>
      </div>
    </div>

    <!-- Products Grid -->
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <div
        v-for="product in productsStore.products"
        :key="product.id"
        class="card hover:shadow-lg transition-shadow duration-200"
        :class="{ 'border-red-200': product.low_stock || product.out_of_stock }"
      >
        <div class="aspect-square bg-gray-100 rounded-lg flex items-center justify-center mb-4 relative">
          <img
            v-if="product.image_url"
            :src="product.image_url"
            :alt="product.name"
            class="w-full h-full object-cover rounded-lg"
            @error="handleImageError(product)"
            @load="handleImageLoad(product)"
          />
          <span v-else class="text-6xl">🕯️</span>
        </div>
        <h3 class="font-semibold text-gray-900 mb-2">{{ product.name }}</h3>
        <p class="text-2xl font-bold text-primary-600 mb-2">{{ product.formatted_price }}</p>
        <div class="flex items-center justify-between mb-4">
          <span
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
            :class="{
              'bg-green-100 text-green-800': product.stock_status === 'in_stock',
              'bg-yellow-100 text-yellow-800': product.stock_status === 'low_stock',
              'bg-red-100 text-red-800': product.stock_status === 'out_of_stock'
            }"
          >
            Stock: {{ product.stock_quantity }}
            <ExclamationTriangleIcon v-if="product.low_stock || product.out_of_stock" class="w-4 h-4 text-amber-500 ml-1" />
          </span>
          <span class="text-sm text-gray-500">SKU: {{ product.sku }}</span>
        </div>
        <div class="flex gap-2">
          <button
            @click="editProduct(product)"
            class="btn btn-secondary flex-1 text-sm py-1.5"
          >
            <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
            </svg>
            Edit
          </button>
          <button
            @click="deleteProduct(product)"
            class="btn btn-danger flex-1 text-sm py-1.5"
          >
            <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
            Delete
          </button>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="productsStore.pagination.total_pages > 1" class="flex items-center justify-between">
      <div class="text-sm text-gray-700">
        Showing <span class="font-medium">{{ (productsStore.pagination.current_page - 1) * productsStore.pagination.per_page + 1 }}</span>
        to <span class="font-medium">{{ Math.min(productsStore.pagination.current_page * productsStore.pagination.per_page, productsStore.pagination.total_count) }}</span>
        of <span class="font-medium">{{ productsStore.pagination.total_count }}</span> results
      </div>
      <nav class="flex items-center space-x-2">
        <button
          @click="changePage(productsStore.pagination.current_page - 1)"
          :disabled="productsStore.pagination.current_page === 1"
          class="btn btn-outline text-sm"
          :class="{ 'opacity-50 cursor-not-allowed': productsStore.pagination.current_page === 1 }"
        >
          Previous
        </button>
        <button
          v-for="page in visiblePages"
          :key="page"
          @click="changePage(page)"
          class="btn text-sm"
          :class="page === productsStore.pagination.current_page ? 'btn-primary' : 'btn-outline'"
        >
          {{ page }}
        </button>
        <button
          @click="changePage(productsStore.pagination.current_page + 1)"
          :disabled="productsStore.pagination.current_page === productsStore.pagination.total_pages"
          class="btn btn-outline text-sm"
          :class="{ 'opacity-50 cursor-not-allowed': productsStore.pagination.current_page === productsStore.pagination.total_pages }"
        >
          Siguiente
        </button>
      </nav>
    </div>

    <!-- Create/Edit Product Modal -->
    <ProductModal
      v-if="showCreateModal || showEditModal"
      :product="editingProduct"
      :is-editing="showEditModal"
      @close="closeModals"
      @save="handleSaveProduct"
    />

    <!-- Delete Confirmation Dialog -->
    <ConfirmDialog
      :show="showDeleteDialog"
      type="danger"
      title="Eliminar Producto"
      :message="`¿Estás seguro de que quieres eliminar '${productToDelete?.name}'?`"
      details="Esta acción no se puede deshacer. El producto será eliminado permanentemente de tu inventario."
      confirm-text="Eliminar"
      cancel-text="Cancelar"
      @confirm="confirmDelete"
      @cancel="cancelDelete"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { CubeIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
import { useProductsStore } from '../stores/products'
import { useNotifications } from '../composables/useNotifications'
import type { Product, ProductFilters } from '../services/products'
import ProductModal from '../components/ProductModal.vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'

const productsStore = useProductsStore()
const { success, error, warning } = useNotifications()

// Reactive state
const searchQuery = ref('')
const selectedCategory = ref('')
const selectedStockStatus = ref('')
const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingProduct = ref<Product | null>(null)
const showDeleteDialog = ref(false)
const productToDelete = ref<Product | null>(null)

// Computed
const visiblePages = computed(() => {
  const pages = []
  const current = productsStore.pagination.current_page
  const total = productsStore.pagination.total_pages

  const start = Math.max(1, current - 2)
  const end = Math.min(total, current + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

// Methods
async function loadProducts() {
  const filters: ProductFilters = {
    page: productsStore.pagination.current_page
  }

  if (searchQuery.value) filters.search = searchQuery.value
  if (selectedCategory.value) filters.category = selectedCategory.value
  if (selectedStockStatus.value) filters.stock_status = selectedStockStatus.value

  try {
    await productsStore.fetchProducts(filters)
  } catch (err: any) {
    console.error('Error loading products:', err)
    error(
      'Error al Cargar Productos',
      'No se pudo obtener tu inventario de productos.',
      err.message || 'Por favor actualiza la página o inténtalo de nuevo más tarde.'
    )
  }
}

function handleSearch() {
  // Debounce search
  setTimeout(() => {
    loadProducts()
  }, 300)
}

function handleFilterChange() {
  loadProducts()
}

function resetFilters() {
  searchQuery.value = ''
  selectedCategory.value = ''
  selectedStockStatus.value = ''
  loadProducts()
}

function changePage(page: number) {
  productsStore.pagination.current_page = page
  loadProducts()
}

function editProduct(product: Product) {
  editingProduct.value = product
  showEditModal.value = true
}

function closeModals() {
  showCreateModal.value = false
  showEditModal.value = false
  editingProduct.value = null
}

async function handleSaveProduct(productData: any) {
  try {
    if (showEditModal.value && editingProduct.value) {
      await productsStore.updateProduct(editingProduct.value.id, productData)
      success(
        'Product Updated',
        `${editingProduct.value.name} has been updated successfully.`
      )
    } else {
      const createdProduct = await productsStore.createProduct(productData)
      success(
        'Product Created',
        `${createdProduct.name} has been added to your inventory.`,
        `SKU: ${createdProduct.sku}`
      )
    }
    closeModals()
    await loadProducts()
  } catch (err: any) {
    console.error('Error saving product:', err)
    error(
      'Failed to Save Product',
      showEditModal.value ? 'Could not update the product.' : 'Could not create the product.',
      err.message || 'Please check your input and try again.'
    )
  }
}

function deleteProduct(product: Product) {
  productToDelete.value = product
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!productToDelete.value) return

  try {
    await productsStore.deleteProduct(productToDelete.value.id)
    success(
      'Product Deleted',
      `${productToDelete.value.name} has been removed from your inventory.`
    )
    await loadProducts()
  } catch (err: any) {
    console.error('Error deleting product:', err)
    error(
      'Failed to Delete Product',
      `Could not delete ${productToDelete.value.name}.`,
      err.message || 'Please try again.'
    )
  } finally {
    showDeleteDialog.value = false
    productToDelete.value = null
  }
}

function cancelDelete() {
  showDeleteDialog.value = false
  productToDelete.value = null
}

function handleImageError(product: Product) {
  console.error(`Failed to load image for product ${product.id}:`, product.image_url)
  console.error('Product data:', product)
}

function handleImageLoad(product: Product) {
  console.log(`Successfully loaded image for product ${product.id}:`, product.image_url)
}

// Lifecycle
onMounted(async () => {
  await loadProducts()

  // Check for low stock products and show warning
  const lowStockCount = productsStore.lowStockCount
  const outOfStockCount = productsStore.outOfStockCount

  if (outOfStockCount > 0) {
    warning(
      'Out of Stock Alert',
      `${outOfStockCount} product${outOfStockCount > 1 ? 's are' : ' is'} out of stock.`,
      'Consider restocking these items to avoid losing sales.'
    )
  } else if (lowStockCount > 0) {
    warning(
      'Low Stock Alert',
      `${lowStockCount} product${lowStockCount > 1 ? 's have' : ' has'} low inventory.`,
      'Consider restocking these items soon.'
    )
  }
})
</script>