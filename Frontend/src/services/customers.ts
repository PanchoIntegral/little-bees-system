import { apiService } from './api'

export interface Customer {
  id: number
  first_name: string
  last_name: string
  email: string
  phone?: string
  address?: string
  created_at: string
  updated_at: string
  full_name: string
}

export interface CustomerFilters {
  search?: string
  sort_by?: 'name' | 'email' | 'created_at'
  page?: number
  per_page?: number
}

export interface CustomerResponse {
  customers: Customer[]
  pagination: {
    current_page: number
    total_pages: number
    total_count: number
    per_page: number
  }
}

export interface CreateCustomerData {
  first_name: string
  last_name: string
  email: string
  phone?: string
  address?: string
}

class CustomersService {
  async getCustomers(filters: CustomerFilters = {}): Promise<CustomerResponse> {
    return apiService.get<CustomerResponse>('/v1/customers', filters)
  }

  async getCustomer(id: number): Promise<Customer> {
    return apiService.get<Customer>(`/v1/customers/${id}`)
  }

  async createCustomer(data: CreateCustomerData): Promise<Customer> {
    return apiService.post<Customer>('/v1/customers', { customer: data })
  }

  async updateCustomer(id: number, data: Partial<CreateCustomerData>): Promise<Customer> {
    return apiService.put<Customer>(`/v1/customers/${id}`, { customer: data })
  }

  async deleteCustomer(id: number): Promise<{ message: string }> {
    return apiService.delete<{ message: string }>(`/v1/customers/${id}`)
  }
}

export const customersService = new CustomersService()