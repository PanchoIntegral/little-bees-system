<template>
  <div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <h1 class="text-3xl font-bold text-gray-900">💰 Sales</h1>
      <div class="flex flex-col sm:flex-row gap-3">
        <div class="relative">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search sales..."
            class="form-input pl-10 pr-4 py-2 w-full sm:w-80"
            @input="handleSearch"
          />
          <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
        </div>
        <button 
          @click="showNewSaleModal = true"
          class="btn btn-primary"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          New Sale
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div class="card">
      <div class="flex flex-wrap gap-4 items-center">
        <span class="text-sm font-medium text-gray-700">Filter by:</span>
        <select 
          v-model="selectedStatus"
          @change="handleFilterChange"
          class="form-input w-auto"
        >
          <option value="">All Status</option>
          <option value="completed">Completed</option>
          <option value="pending">Pending</option>
          <option value="cancelled">Cancelled</option>
        </select>
        <select 
          v-model="selectedPaymentMethod"
          @change="handleFilterChange"
          class="form-input w-auto"
        >
          <option value="">All Payment Methods</option>
          <option value="cash">Cash</option>
          <option value="credit_card">Credit Card</option>
          <option value="debit_card">Debit Card</option>
          <option value="digital_wallet">Digital Wallet</option>
        </select>
        <input 
          v-model="selectedDate"
          @change="handleFilterChange"
          type="date" 
          class="form-input w-auto" 
        />
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
    <div v-if="salesStore.loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
    </div>

    <!-- Error State -->
    <div v-if="salesStore.error" class="bg-red-50 border border-red-200 rounded-md p-4">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error loading sales</h3>
          <div class="mt-2 text-sm text-red-700">
            <p>{{ salesStore.error }}</p>
          </div>
          <div class="mt-4">
            <button
              @click="loadSales"
              class="btn btn-secondary"
            >
              Try again
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="!salesStore.loading && salesStore.sales.length === 0" class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No sales found</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new sale.</p>
      <div class="mt-6">
        <button
          @click="showNewSaleModal = true"
          class="btn btn-primary"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          New Sale
        </button>
      </div>
    </div>

    <!-- Sales Table -->
    <div v-else class="card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Items</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr 
              v-for="sale in salesStore.sales"
              :key="sale.id"
              class="hover:bg-gray-50"
            >
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ sale.receipt_number }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(sale.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ sale.customer_name || 'Walk-in Customer' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ sale.items_count }} {{ sale.items_count === 1 ? 'item' : 'items' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                {{ sale.formatted_total }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span 
                  class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-green-100 text-green-800': sale.status === 'completed',
                    'bg-yellow-100 text-yellow-800': sale.status === 'pending',
                    'bg-red-100 text-red-800': sale.status === 'cancelled',
                    'bg-blue-100 text-blue-800': sale.status === 'refunded'
                  }"
                >
                  {{ sale.status_display }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button 
                  @click="viewSale(sale)"
                  class="btn btn-secondary text-sm py-1"
                >
                  View
                </button>
                <button 
                  v-if="sale.status === 'pending'"
                  @click="completeSale(sale.id)"
                  class="btn btn-primary text-sm py-1"
                >
                  Complete
                </button>
                <button 
                  v-if="sale.status === 'completed'"
                  @click="generateReceipt(sale.id)"
                  class="btn btn-primary text-sm py-1"
                >
                  Receipt
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="salesStore.pagination.total_pages > 1" class="flex items-center justify-between">
      <div class="text-sm text-gray-700">
        Showing <span class="font-medium">{{ (salesStore.pagination.current_page - 1) * salesStore.pagination.per_page + 1 }}</span>
        to <span class="font-medium">{{ Math.min(salesStore.pagination.current_page * salesStore.pagination.per_page, salesStore.pagination.total_count) }}</span>
        of <span class="font-medium">{{ salesStore.pagination.total_count }}</span> results
      </div>
      <nav class="flex items-center space-x-2">
        <button
          @click="changePage(salesStore.pagination.current_page - 1)"
          :disabled="salesStore.pagination.current_page === 1"
          class="btn btn-outline text-sm"
          :class="{ 'opacity-50 cursor-not-allowed': salesStore.pagination.current_page === 1 }"
        >
          Previous
        </button>
        <button
          v-for="page in visiblePages"
          :key="page"
          @click="changePage(page)"
          class="btn text-sm"
          :class="page === salesStore.pagination.current_page ? 'btn-primary' : 'btn-outline'"
        >
          {{ page }}
        </button>
        <button
          @click="changePage(salesStore.pagination.current_page + 1)"
          :disabled="salesStore.pagination.current_page === salesStore.pagination.total_pages"
          class="btn btn-outline text-sm"
          :class="{ 'opacity-50 cursor-not-allowed': salesStore.pagination.current_page === salesStore.pagination.total_pages }"
        >
          Next
        </button>
      </nav>
    </div>

    <!-- New Sale Modal -->
    <NewSaleModal
      v-if="showNewSaleModal"
      @close="showNewSaleModal = false"
      @success="handleSaleSuccess"
    />

    <!-- Sale Details Modal (placeholder) -->
    <div v-if="showSaleDetails && selectedSale" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" @click="closeSaleDetails">
      <div class="relative top-10 mx-auto p-5 border w-[600px] shadow-lg rounded-md bg-white" @click.stop>
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Sale Details - {{ selectedSale.receipt_number }}</h3>
          <div class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="text-sm font-medium text-gray-700">Date:</label>
                <p class="text-gray-900">{{ formatDate(selectedSale.created_at) }}</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Customer:</label>
                <p class="text-gray-900">{{ selectedSale.customer_name || 'Walk-in Customer' }}</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Payment Method:</label>
                <p class="text-gray-900">{{ selectedSale.payment_method_display }}</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Status:</label>
                <span 
                  class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-green-100 text-green-800': selectedSale.status === 'completed',
                    'bg-yellow-100 text-yellow-800': selectedSale.status === 'pending',
                    'bg-red-100 text-red-800': selectedSale.status === 'cancelled',
                    'bg-blue-100 text-blue-800': selectedSale.status === 'refunded'
                  }"
                >
                  {{ selectedSale.status_display }}
                </span>
              </div>
            </div>
            
            <div>
              <h4 class="text-sm font-medium text-gray-700 mb-2">Items:</h4>
              <div class="space-y-2">
                <div v-for="item in selectedSale.sale_items" :key="item.id" class="flex justify-between items-center bg-gray-50 p-2 rounded">
                  <div>
                    <p class="font-medium">{{ item.product.name }}</p>
                    <p class="text-sm text-gray-500">{{ item.quantity }}x @ {{ formatCurrency(item.unit_price) }}</p>
                  </div>
                  <p class="font-semibold">{{ formatCurrency(item.line_total) }}</p>
                </div>
              </div>
            </div>
            
            <div class="border-t pt-4">
              <div class="flex justify-between text-lg font-bold">
                <span>Total:</span>
                <span>{{ selectedSale.formatted_total }}</span>
              </div>
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 mt-6">
            <button
              @click="closeSaleDetails"
              class="btn btn-secondary"
            >
              Close
            </button>
            <button
              v-if="selectedSale.status === 'completed'"
              @click="generateReceipt(selectedSale.id)"
              class="btn btn-primary"
            >
              Generate Receipt
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useSalesStore } from '../stores/sales'
import type { Sale, SaleFilters } from '../services/sales'
import { pdfService } from '../services/pdf'
import NewSaleModal from '../components/NewSaleModal.vue'

const salesStore = useSalesStore()

// Reactive state
const searchQuery = ref('')
const selectedStatus = ref('')
const selectedPaymentMethod = ref('')
const selectedDate = ref('')
const showNewSaleModal = ref(false)
const showSaleDetails = ref(false)
const selectedSale = ref<Sale | null>(null)

// Computed
const visiblePages = computed(() => {
  const pages = []
  const current = salesStore.pagination.current_page
  const total = salesStore.pagination.total_pages

  const start = Math.max(1, current - 2)
  const end = Math.min(total, current + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

// Methods
async function loadSales() {
  const filters: SaleFilters = {
    page: salesStore.pagination.current_page
  }

  if (searchQuery.value) filters.query = searchQuery.value
  if (selectedStatus.value) filters.status = selectedStatus.value
  if (selectedPaymentMethod.value) filters.payment_method = selectedPaymentMethod.value
  if (selectedDate.value) {
    filters.start_date = selectedDate.value
    filters.end_date = selectedDate.value
  }

  await salesStore.fetchSales(filters)
}

function handleSearch() {
  // Debounce search
  setTimeout(() => {
    loadSales()
  }, 300)
}

function handleFilterChange() {
  loadSales()
}

function resetFilters() {
  searchQuery.value = ''
  selectedStatus.value = ''
  selectedPaymentMethod.value = ''
  selectedDate.value = ''
  loadSales()
}

function changePage(page: number) {
  salesStore.pagination.current_page = page
  loadSales()
}

function viewSale(sale: Sale) {
  selectedSale.value = sale
  showSaleDetails.value = true
}

function closeSaleDetails() {
  showSaleDetails.value = false
  selectedSale.value = null
}

async function completeSale(saleId: number) {
  if (confirm('Are you sure you want to complete this sale?')) {
    try {
      await salesStore.completeSale(saleId)
      await loadSales()
    } catch (error) {
      console.error('Error completing sale:', error)
    }
  }
}

async function generateReceipt(saleId: number) {
  try {
    // Find the sale in our store or fetch it
    let sale = salesStore.sales.find(s => s.id === saleId)
    
    if (!sale) {
      // If not found in store, fetch it
      await salesStore.fetchSale(saleId)
      sale = salesStore.currentSale
    }
    
    if (!sale) {
      throw new Error('Sale not found')
    }
    
    // Generate the PDF receipt
    await pdfService.generateReceipt(sale)
    
  } catch (error) {
    console.error('Error generating receipt:', error)
    alert('Error al generar el recibo. Por favor, inténtalo de nuevo.')
  }
}

function handleSaleSuccess(sale: Sale) {
  console.log('Sale created successfully:', sale)
  loadSales()
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString()
}

function formatCurrency(amount: number | string) {
  const numAmount = parseFloat(amount as string) || 0
  return `$${numAmount.toFixed(2)}`
}

// Lifecycle
onMounted(() => {
  loadSales()
})
</script>