<template>
  <div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div class="flex items-center">
        <div class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-emerald-600 rounded-xl flex items-center justify-center mr-4">
          <CurrencyDollarIcon class="w-6 h-6 text-white" />
        </div>
        <div>
          <h1 class="text-3xl font-bold text-gray-900">Sales</h1>
          <p class="text-gray-600 text-sm mt-1">Manage and track all your sales transactions</p>
        </div>
      </div>
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
        <div class="flex gap-3">
          <!-- Admin-only Delete Selected Sales button -->
          <div v-if="isAdmin" class="flex gap-3">
            <button
              v-if="!selectionModeActive"
              @click="selectionModeActive = true"
              class="btn btn-secondary"
            >
              Manage Sales
            </button>
            <template v-else>
              <button
                @click="showDeleteConfirmation = true"
                class="btn btn-danger"
                :disabled="salesStore.loading || selectedSales.length === 0"
              >
                Delete Selected ({{ selectedSales.length }})
              </button>
              <button
                @click="cancelSelectionMode"
                class="btn btn-outline"
              >
                Cancel
              </button>
            </template>
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
    </div>

    <!-- Filters -->
    <div class="card-elevated">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-gray-900 flex items-center">
          <FunnelIcon class="w-5 h-5 text-gray-500 mr-2" />
          Filters
        </h3>
        <span class="text-sm text-gray-500">{{ salesStore.sales.length }} sales found</span>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-4 lg:grid-cols-5 gap-4">
        <div class="form-group">
          <label class="form-label">Status</label>
          <select
            v-model="selectedStatus"
            @change="handleFilterChange"
            class="form-input"
          >
            <option value="">All Status</option>
            <option value="completed">Completed</option>
            <option value="pending">Pending</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label">Payment Method</label>
          <select
            v-model="selectedPaymentMethod"
            @change="handleFilterChange"
            class="form-input"
          >
            <option value="">All Methods</option>
            <option value="cash">Cash</option>
            <option value="credit_card">Credit Card</option>
            <option value="debit_card">Debit Card</option>
            <option value="digital_wallet">Digital Wallet</option>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label">Date</label>
          <input
            v-model="selectedDate"
            @change="handleFilterChange"
            type="date"
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label class="form-label invisible">Actions</label>
          <button
            @click="resetFilters"
            class="btn btn-outline w-full"
          >
            <ArrowPathIcon class="w-4 h-4 mr-2" />
            Reset
          </button>
        </div>

        <div class="form-group">
          <label class="form-label invisible">Export</label>
          <button
            @click="exportSales"
            class="btn btn-success w-full"
            :disabled="salesStore.loading"
          >
            <DocumentArrowDownIcon class="w-4 h-4 mr-2" />
            Export
          </button>
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div v-if="!salesStore.loading && salesStore.sales.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <!-- Total Sales -->
      <div class="card-elevated">
        <div class="flex items-start justify-between">
          <div class="flex-shrink-0">
            <div class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-emerald-600 rounded-xl flex items-center justify-center">
              <CurrencyDollarIcon class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <p class="text-sm font-medium text-gray-600 mb-1">Total Sales</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            {{ formatCurrency(totalSalesAmount) }}
          </p>
          <p class="text-sm text-gray-500 mt-1">From {{ salesStore.sales.length }} transactions</p>
        </div>
      </div>

      <!-- Average Sale -->
      <div class="card-elevated">
        <div class="flex items-start justify-between">
          <div class="flex-shrink-0">
            <div class="w-12 h-12 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl flex items-center justify-center">
              <ChartBarIcon class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <p class="text-sm font-medium text-gray-600 mb-1">Average Sale</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            {{ formatCurrency(averageSaleAmount) }}
          </p>
          <p class="text-sm text-gray-500 mt-1">Per transaction</p>
        </div>
      </div>

      <!-- Completed Sales -->
      <div class="card-elevated">
        <div class="flex items-start justify-between">
          <div class="flex-shrink-0">
            <div class="w-12 h-12 bg-gradient-to-r from-green-500 to-green-600 rounded-xl flex items-center justify-center">
              <CheckCircleIcon class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <p class="text-sm font-medium text-gray-600 mb-1">Completed Sales</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            {{ completedSalesCount }}
          </p>
          <p class="text-sm text-gray-500 mt-1">{{ ((completedSalesCount / salesStore.sales.length) * 100).toFixed(1) }}% completion rate</p>
        </div>
      </div>

      <!-- Today's Sales -->
      <div class="card-elevated">
        <div class="flex items-start justify-between">
          <div class="flex-shrink-0">
            <div class="w-12 h-12 bg-gradient-to-r from-purple-500 to-purple-600 rounded-xl flex items-center justify-center">
              <CalendarDaysIcon class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <p class="text-sm font-medium text-gray-600 mb-1">Today's Sales</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            {{ formatCurrency(todaySalesAmount) }}
          </p>
          <p class="text-sm text-gray-500 mt-1">{{ todaySalesCount }} transactions today</p>
        </div>
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
              <th v-if="selectionModeActive" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                <input type="checkbox" @change="toggleSelectAll" :checked="isAllSelected" class="form-checkbox h-4 w-4 text-primary-600 transition duration-150 ease-in-out" />
              </th>
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
              class="hover:bg-gray-50 transition-colors duration-150"
              :class="{ 'bg-primary-50': selectedSales.includes(sale.id) }"
            >
              <td v-if="selectionModeActive" class="px-6 py-4 whitespace-nowrap">
                <input type="checkbox" :value="sale.id" v-model="selectedSales" class="form-checkbox h-4 w-4 text-primary-600 transition duration-150 ease-in-out" />
              </td>
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

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteConfirmation" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" @click="showDeleteConfirmation = false">
      <div class="relative top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 p-5 border w-96 shadow-lg rounded-md bg-white" @click.stop>
        <div class="mt-3 text-center">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100">
            <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
            </svg>
          </div>
          <div class="flex items-center mt-2">
            <ExclamationTriangleIcon class="w-5 h-5 text-red-500 mr-2" />
            <h3 class="text-lg font-medium text-gray-900">Delete Sales</h3>
          </div>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Are you sure you want to delete <strong>{{ selectedSales.length }} selected sales</strong>? This action cannot be undone.
            </p>
          </div>
          <div class="flex justify-center space-x-3 mt-4">
            <button
              @click="showDeleteConfirmation = false"
              class="btn btn-secondary"
            >
              Cancel
            </button>
            <button
              @click="deleteSelectedSales"
              :disabled="deletingSales"
              class="btn btn-danger"
            >
              <span v-if="deletingSales" class="flex items-center">
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Deleting...
              </span>
              <span v-else>Yes, Delete</span>
            </button>
          </div>
        </div>
      </div>
    </div>

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
import { ref, computed, onMounted, watch } from 'vue'
import {
  ExclamationTriangleIcon,
  CurrencyDollarIcon,
  FunnelIcon,
  ArrowPathIcon,
  DocumentArrowDownIcon,
  ChartBarIcon,
  CheckCircleIcon,
  CalendarDaysIcon
} from '@heroicons/vue/24/outline'
import { useSalesStore } from '../stores/sales'
import type { Sale, SaleFilters } from '../services/sales'
import { salesService } from '../services/sales'
import { pdfService } from '../services/pdf'
import { authService } from '../services/auth'
import { useNotifications } from '../composables/useNotifications'
import NewSaleModal from '../components/NewSaleModal.vue'

const salesStore = useSalesStore()
const { success: showSuccess, error: showError } = useNotifications()

// Reactive state
const searchQuery = ref('')
const selectedStatus = ref('')
const selectedPaymentMethod = ref('')
const selectedDate = ref('')
const showNewSaleModal = ref(false)
const showSaleDetails = ref(false)
const selectedSale = ref<Sale | null>(null)
const showDeleteConfirmation = ref(false)
const deletingSales = ref(false)
const selectedSales = ref<number[]>([])
const selectionModeActive = ref(false)

// Computed
const isAdmin = computed(() => {
  return authService.currentUser.value?.role === 'admin'
})

const isAllSelected = computed(() => {
  return salesStore.sales.length > 0 && selectedSales.value.length === salesStore.sales.length
})

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

// Statistics computed properties
const totalSalesAmount = computed(() => {
  return salesStore.sales.reduce((total, sale) => total + parseFloat(sale.total_amount), 0)
})

const averageSaleAmount = computed(() => {
  return salesStore.sales.length > 0 ? totalSalesAmount.value / salesStore.sales.length : 0
})

const completedSalesCount = computed(() => {
  return salesStore.sales.filter(sale => sale.status === 'completed').length
})

const todaySalesAmount = computed(() => {
  const today = new Date().toDateString()
  return salesStore.sales
    .filter(sale => new Date(sale.sale_date).toDateString() === today)
    .reduce((total, sale) => total + parseFloat(sale.total_amount), 0)
})

const todaySalesCount = computed(() => {
  const today = new Date().toDateString()
  return salesStore.sales.filter(sale => new Date(sale.sale_date).toDateString() === today).length
})

// Watch for page changes to clear selection
watch(() => salesStore.pagination.current_page, () => {
  selectedSales.value = []
})

// Methods
async function loadSales() {
  const filters: SaleFilters = {
    page: salesStore.pagination.current_page
  }

  if (searchQuery.value) filters.search = searchQuery.value
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
    let sale = salesStore.sales.find(s => s.id === saleId)
    
    if (!sale) {
      await salesStore.fetchSale(saleId)
      sale = salesStore.currentSale
    }
    
    if (!sale) {
      throw new Error('Sale not found')
    }
    
    await pdfService.generateReceipt(sale)
    
  } catch (error) {
    console.error('Error generating receipt:', error)
    alert('Error al generar el recibo. Por favor, inténtalo de nuevo.')
  }
}

async function deleteSelectedSales() {
  if (!isAdmin.value) {
    showError('Unauthorized', 'Admin access required.')
    return
  }

  deletingSales.value = true

  try {
    const response = await salesStore.bulkDeleteSales(selectedSales.value)

    showSuccess('Sales Deleted', `Successfully deleted ${response.deleted_count} sales`)

    showDeleteConfirmation.value = false
    selectedSales.value = [] // Clear selection
    selectionModeActive.value = false // Exit selection mode

  } catch (error: any) {
    console.error('Error deleting sales:', error)
    showError('Error Deleting Sales', error.message || 'Failed to delete sales. Please try again.')

  } finally {
    deletingSales.value = false
  }
}

function toggleSelectAll(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.checked) {
    selectedSales.value = salesStore.sales.map(s => s.id)
  } else {
    selectedSales.value = []
  }
}

function cancelSelectionMode() {
  selectionModeActive.value = false
  selectedSales.value = []
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

function exportSales() {
  try {
    const salesData = salesStore.sales.map(sale => ({
      ID: sale.id,
      Date: formatDate(sale.sale_date),
      Customer: sale.customer_name || 'N/A',
      Total: formatCurrency(sale.total_amount),
      'Payment Method': sale.payment_method,
      Status: sale.status
    }))

    const csvContent = "data:text/csv;charset=utf-8,"
      + "ID,Date,Customer,Total,Payment Method,Status\n"
      + salesData.map(row => Object.values(row).join(",")).join("\n")

    const encodedUri = encodeURI(csvContent)
    const link = document.createElement("a")
    link.setAttribute("href", encodedUri)
    link.setAttribute("download", `sales_export_${new Date().toISOString().split('T')[0]}.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    success('Export Successful', 'Sales data has been exported to CSV file')
  } catch (error) {
    error('Export Failed', 'Unable to export sales data. Please try again.')
  }
}

// Lifecycle
onMounted(() => {
  loadSales()
})
</script>

<style scoped>
/* Add any component-specific styles here */
</style>