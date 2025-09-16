import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { productsService, Product, ProductFilters, CreateProductData } from '../services/products'

export const useProductsStore = defineStore('products', () => {
  // State
  const products = ref<Product[]>([])
  const currentProduct = ref<Product | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const pagination = ref({
    current_page: 1,
    total_pages: 1,
    total_count: 0,
    per_page: 20
  })

  // Getters
  const lowStockProducts = computed(() =>
    products.value.filter(product => product.low_stock)
  )

  const outOfStockProducts = computed(() =>
    products.value.filter(product => product.out_of_stock)
  )

  const categories = computed(() => {
    const cats = new Set(products.value.map(p => p.category))
    return Array.from(cats).sort()
  })

  const lowStockCount = computed(() => lowStockProducts.value.length)
  const outOfStockCount = computed(() => outOfStockProducts.value.length)

  // Actions
  async function fetchProducts(filters: ProductFilters = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await productsService.getProducts(filters)
      products.value = response.products
      pagination.value = response.pagination
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch products'
      console.error('Error fetching products:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchProduct(id: number) {
    loading.value = true
    error.value = null

    try {
      currentProduct.value = await productsService.getProduct(id)
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch product'
      console.error('Error fetching product:', err)
    } finally {
      loading.value = false
    }
  }

  async function createProduct(data: CreateProductData | FormData) {
    loading.value = true
    error.value = null

    try {
      const newProduct = await productsService.createProduct(data)
      products.value.unshift(newProduct)
      return newProduct
    } catch (err: any) {
      error.value = err.response?.data?.errors || err.response?.data?.error || 'Failed to create product'
      console.error('Error creating product:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateProduct(id: number, data: Partial<CreateProductData> | FormData) {
    loading.value = true
    error.value = null

    try {
      const updatedProduct = await productsService.updateProduct(id, data)
      const index = products.value.findIndex(p => p.id === id)
      if (index !== -1) {
        products.value[index] = updatedProduct
      }
      if (currentProduct.value?.id === id) {
        currentProduct.value = updatedProduct
      }
      return updatedProduct
    } catch (err: any) {
      error.value = err.response?.data?.errors || err.response?.data?.error || 'Failed to update product'
      console.error('Error updating product:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteProduct(id: number) {
    loading.value = true
    error.value = null

    try {
      await productsService.deleteProduct(id)
      products.value = products.value.filter(p => p.id !== id)
      if (currentProduct.value?.id === id) {
        currentProduct.value = null
      }
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to delete product'
      console.error('Error deleting product:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  function clearError() {
    error.value = null
  }

  function clearCurrentProduct() {
    currentProduct.value = null
  }

  return {
    // State
    products,
    currentProduct,
    loading,
    error,
    pagination,

    // Getters
    lowStockProducts,
    outOfStockProducts,
    categories,
    lowStockCount,
    outOfStockCount,

    // Actions
    fetchProducts,
    fetchProduct,
    createProduct,
    updateProduct,
    deleteProduct,
    clearError,
    clearCurrentProduct
  }
})