import { defineStore } from 'pinia'
import { ref } from 'vue'
import { customersService, Customer, CustomerFilters, CreateCustomerData } from '../services/customers'

export const useCustomersStore = defineStore('customers', () => {
  // State
  const customers = ref<Customer[]>([])
  const currentCustomer = ref<Customer | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const pagination = ref({
    current_page: 1,
    total_pages: 1,
    total_count: 0,
    per_page: 20
  })

  // Actions
  async function fetchCustomers(filters: CustomerFilters = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await customersService.getCustomers(filters)
      customers.value = response.customers
      pagination.value = response.pagination
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch customers'
      console.error('Error fetching customers:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchCustomer(id: number) {
    loading.value = true
    error.value = null

    try {
      currentCustomer.value = await customersService.getCustomer(id)
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch customer'
      console.error('Error fetching customer:', err)
    } finally {
      loading.value = false
    }
  }

  async function createCustomer(data: CreateCustomerData) {
    loading.value = true
    error.value = null

    try {
      const newCustomer = await customersService.createCustomer(data)
      customers.value.unshift(newCustomer)
      return newCustomer
    } catch (err: any) {
      error.value = err.response?.data?.errors || err.response?.data?.error || 'Failed to create customer'
      console.error('Error creating customer:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateCustomer(id: number, data: Partial<CreateCustomerData>) {
    loading.value = true
    error.value = null

    try {
      const updatedCustomer = await customersService.updateCustomer(id, data)
      const index = customers.value.findIndex(c => c.id === id)
      if (index !== -1) {
        customers.value[index] = updatedCustomer
      }
      if (currentCustomer.value?.id === id) {
        currentCustomer.value = updatedCustomer
      }
      return updatedCustomer
    } catch (err: any) {
      error.value = err.response?.data?.errors || err.response?.data?.error || 'Failed to update customer'
      console.error('Error updating customer:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteCustomer(id: number) {
    loading.value = true
    error.value = null

    try {
      await customersService.deleteCustomer(id)
      customers.value = customers.value.filter(c => c.id !== id)
      if (currentCustomer.value?.id === id) {
        currentCustomer.value = null
      }
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to delete customer'
      console.error('Error deleting customer:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  function clearError() {
    error.value = null
  }

  function clearCurrentCustomer() {
    currentCustomer.value = null
  }

  return {
    // State
    customers,
    currentCustomer,
    loading,
    error,
    pagination,

    // Actions
    fetchCustomers,
    fetchCustomer,
    createCustomer,
    updateCustomer,
    deleteCustomer,
    clearError,
    clearCurrentCustomer
  }
})