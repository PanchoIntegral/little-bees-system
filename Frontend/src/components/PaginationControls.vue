<template>
  <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
    <!-- Mobile View -->
    <div class="flex-1 flex justify-between sm:hidden">
      <button
        @click="goToPrevious"
        :disabled="!pagination.has_prev_page"
        class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Anterior
      </button>
      <button
        @click="goToNext"
        :disabled="!pagination.has_next_page"
        class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Siguiente
      </button>
    </div>

    <!-- Desktop View -->
    <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
      <!-- Results Info -->
      <div>
        <p class="text-sm text-gray-700">
          <template v-if="pagination.total_count !== undefined">
            Mostrando
            <span class="font-medium">{{ startItem }}</span>
            a
            <span class="font-medium">{{ endItem }}</span>
            de
            <span class="font-medium">{{ pagination.total_count }}</span>
            resultados
          </template>
          <template v-else>
            Página {{ pagination.current_page }}
            <template v-if="showPerPageInfo">
              ({{ pagination.per_page }} por página)
            </template>
          </template>
        </p>
      </div>

      <!-- Pagination Navigation -->
      <div>
        <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
          <!-- Previous Button -->
          <button
            @click="goToPrevious"
            :disabled="!pagination.has_prev_page"
            class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span class="sr-only">Anterior</span>
            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </button>

          <!-- Page Numbers (only show if we have total pages) -->
          <template v-if="pagination.total_pages">
            <!-- First Page -->
            <button
              v-if="showFirstPage"
              @click="goToPage(1)"
              class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              1
            </button>

            <!-- First Ellipsis -->
            <span v-if="showFirstEllipsis" class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700">
              ...
            </span>

            <!-- Visible Page Numbers -->
            <button
              v-for="page in visiblePages"
              :key="page"
              @click="goToPage(page)"
              :class="[
                'relative inline-flex items-center px-4 py-2 border text-sm font-medium',
                page === pagination.current_page
                  ? 'z-10 bg-indigo-50 border-indigo-500 text-indigo-600'
                  : 'bg-white border-gray-300 text-gray-700 hover:bg-gray-50'
              ]"
            >
              {{ page }}
            </button>

            <!-- Last Ellipsis -->
            <span v-if="showLastEllipsis" class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700">
              ...
            </span>

            <!-- Last Page -->
            <button
              v-if="showLastPage"
              @click="goToPage(pagination.total_pages)"
              class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              {{ pagination.total_pages }}
            </button>
          </template>

          <!-- Current Page Indicator (when total is unknown) -->
          <span v-else class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-indigo-50 text-sm font-medium text-indigo-600">
            {{ pagination.current_page }}
          </span>

          <!-- Next Button -->
          <button
            @click="goToNext"
            :disabled="!pagination.has_next_page"
            class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span class="sr-only">Siguiente</span>
            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
            </svg>
          </button>
        </nav>
      </div>
    </div>

    <!-- Per Page Selector -->
    <div class="hidden sm:block ml-4" v-if="showPerPageSelector">
      <select
        :value="pagination.per_page"
        @change="changePerPage($event.target.value)"
        class="form-select text-sm border-gray-300 rounded-md"
      >
        <option v-for="size in perPageOptions" :key="size" :value="size">
          {{ size }} por página
        </option>
      </select>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { PaginationMeta } from '../services/products'

interface Props {
  pagination: PaginationMeta
  showPerPageSelector?: boolean
  showPerPageInfo?: boolean
  perPageOptions?: number[]
  maxVisiblePages?: number
}

interface Emits {
  (e: 'page-change', page: number): void
  (e: 'per-page-change', perPage: number): void
}

const props = withDefaults(defineProps<Props>(), {
  showPerPageSelector: true,
  showPerPageInfo: true,
  perPageOptions: () => [10, 20, 50, 100],
  maxVisiblePages: 5
})

const emit = defineEmits<Emits>()

// Computed properties
const startItem = computed(() => {
  if (!props.pagination.total_count) return 0
  return (props.pagination.current_page - 1) * props.pagination.per_page + 1
})

const endItem = computed(() => {
  if (!props.pagination.total_count) return 0
  const calculated = props.pagination.current_page * props.pagination.per_page
  return Math.min(calculated, props.pagination.total_count)
})

const visiblePages = computed(() => {
  if (!props.pagination.total_pages) return []

  const current = props.pagination.current_page
  const total = props.pagination.total_pages
  const maxVisible = props.maxVisiblePages

  const half = Math.floor(maxVisible / 2)
  let start = current - half
  let end = current + half

  if (start < 1) {
    start = 1
    end = Math.min(maxVisible, total)
  }

  if (end > total) {
    end = total
    start = Math.max(1, total - maxVisible + 1)
  }

  const pages = []
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

const showFirstPage = computed(() => {
  return props.pagination.total_pages &&
         props.pagination.total_pages > props.maxVisiblePages &&
         !visiblePages.value.includes(1)
})

const showLastPage = computed(() => {
  return props.pagination.total_pages &&
         props.pagination.total_pages > props.maxVisiblePages &&
         !visiblePages.value.includes(props.pagination.total_pages)
})

const showFirstEllipsis = computed(() => {
  return showFirstPage.value && visiblePages.value[0] > 2
})

const showLastEllipsis = computed(() => {
  return showLastPage.value &&
         props.pagination.total_pages &&
         visiblePages.value[visiblePages.value.length - 1] < props.pagination.total_pages - 1
})

// Methods
function goToPage(page: number) {
  if (page !== props.pagination.current_page) {
    emit('page-change', page)
  }
}

function goToPrevious() {
  if (props.pagination.has_prev_page) {
    goToPage(props.pagination.current_page - 1)
  }
}

function goToNext() {
  if (props.pagination.has_next_page) {
    goToPage(props.pagination.current_page + 1)
  }
}

function changePerPage(newPerPage: string) {
  const perPage = parseInt(newPerPage)
  if (perPage !== props.pagination.per_page) {
    emit('per-page-change', perPage)
  }
}
</script>