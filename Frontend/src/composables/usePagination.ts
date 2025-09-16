import { ref, computed, watch } from 'vue'
import type { PaginationMeta } from '../services/products'

export interface PaginationConfig {
  defaultPerPage?: number
  maxPerPage?: number
  includeTotalOnFirstPage?: boolean
}

export function usePagination(config: PaginationConfig = {}) {
  const {
    defaultPerPage = 20,
    maxPerPage = 100,
    includeTotalOnFirstPage = true
  } = config

  // Reactive state
  const currentPage = ref(1)
  const perPage = ref(defaultPerPage)
  const paginationMeta = ref<PaginationMeta>({
    current_page: 1,
    per_page: defaultPerPage,
    has_next_page: null,
    has_prev_page: false
  })

  // Computed properties
  const paginationParams = computed(() => ({
    page: currentPage.value,
    per_page: perPage.value,
    include_total: includeTotalOnFirstPage && currentPage.value === 1 ? 'true' : 'false'
  }))

  const hasNextPage = computed(() => paginationMeta.value.has_next_page === true)
  const hasPrevPage = computed(() => paginationMeta.value.has_prev_page === true)
  const isFirstPage = computed(() => paginationMeta.value.is_first_page === true)
  const isLastPage = computed(() => paginationMeta.value.is_last_page === true)

  const totalPages = computed(() => paginationMeta.value.total_pages)
  const totalCount = computed(() => paginationMeta.value.total_count)

  // Methods
  function updatePagination(meta: PaginationMeta) {
    paginationMeta.value = meta
    currentPage.value = meta.current_page
    perPage.value = meta.per_page
  }

  function goToPage(page: number) {
    if (page < 1) return

    // If we don't know total pages, allow navigation
    if (!totalPages.value || page <= totalPages.value) {
      currentPage.value = page
    }
  }

  function goToNext() {
    if (hasNextPage.value) {
      currentPage.value += 1
    }
  }

  function goToPrevious() {
    if (hasPrevPage.value) {
      currentPage.value -= 1
    }
  }

  function goToFirst() {
    currentPage.value = 1
  }

  function goToLast() {
    if (totalPages.value) {
      currentPage.value = totalPages.value
    }
  }

  function setPerPage(newPerPage: number) {
    if (newPerPage < 1 || newPerPage > maxPerPage) return

    perPage.value = newPerPage
    // Reset to first page when changing per page
    currentPage.value = 1
  }

  function reset() {
    currentPage.value = 1
    perPage.value = defaultPerPage
    paginationMeta.value = {
      current_page: 1,
      per_page: defaultPerPage,
      has_next_page: null,
      has_prev_page: false
    }
  }

  // Calculate item range for display
  const itemRange = computed(() => {
    if (!totalCount.value) {
      return {
        start: (currentPage.value - 1) * perPage.value + 1,
        end: null,
        total: null
      }
    }

    const start = (currentPage.value - 1) * perPage.value + 1
    const end = Math.min(currentPage.value * perPage.value, totalCount.value)

    return {
      start,
      end,
      total: totalCount.value
    }
  })

  // Provide pagination info for URL/state management
  const paginationState = computed(() => ({
    page: currentPage.value,
    per_page: perPage.value
  }))

  // Watch for page changes to emit events
  const pageChangeCallbacks = ref<Array<(page: number) => void>>([])
  const perPageChangeCallbacks = ref<Array<(perPage: number) => void>>([])

  watch(currentPage, (newPage, oldPage) => {
    if (newPage !== oldPage) {
      pageChangeCallbacks.value.forEach(callback => callback(newPage))
    }
  })

  watch(perPage, (newPerPage, oldPerPage) => {
    if (newPerPage !== oldPerPage) {
      perPageChangeCallbacks.value.forEach(callback => callback(newPerPage))
    }
  })

  function onPageChange(callback: (page: number) => void) {
    pageChangeCallbacks.value.push(callback)

    // Return cleanup function
    return () => {
      const index = pageChangeCallbacks.value.indexOf(callback)
      if (index > -1) {
        pageChangeCallbacks.value.splice(index, 1)
      }
    }
  }

  function onPerPageChange(callback: (perPage: number) => void) {
    perPageChangeCallbacks.value.push(callback)

    // Return cleanup function
    return () => {
      const index = perPageChangeCallbacks.value.indexOf(callback)
      if (index > -1) {
        perPageChangeCallbacks.value.splice(index, 1)
      }
    }
  }

  return {
    // State
    currentPage: computed(() => currentPage.value),
    perPage: computed(() => perPage.value),
    paginationMeta: computed(() => paginationMeta.value),

    // Computed
    paginationParams,
    hasNextPage,
    hasPrevPage,
    isFirstPage,
    isLastPage,
    totalPages,
    totalCount,
    itemRange,
    paginationState,

    // Methods
    updatePagination,
    goToPage,
    goToNext,
    goToPrevious,
    goToFirst,
    goToLast,
    setPerPage,
    reset,
    onPageChange,
    onPerPageChange
  }
}