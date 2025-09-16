import { apiService } from './api'

export interface Product {
  id: number
  name: string
  description?: string
  price: number
  sku: string
  category: string
  stock_quantity: number
  low_stock_threshold: number
  image_url?: string
  active: boolean
  created_at: string
  updated_at: string
  formatted_price: string
  stock_status: 'in_stock' | 'low_stock' | 'out_of_stock'
  stock_status_color: 'green' | 'yellow' | 'red'
  in_stock: boolean
  out_of_stock: boolean
  low_stock: boolean
  total_sold: number
  revenue_generated: number
}

export interface ProductFilters {
  search?: string
  category?: string
  active?: boolean
  stock_status?: 'in_stock' | 'low_stock' | 'out_of_stock'
  sort_by?: 'name' | 'price' | 'stock'
  page?: number
  per_page?: number
}

export interface ProductResponse {
  products: Product[]
  pagination: {
    current_page: number
    total_pages: number
    total_count: number
    per_page: number
  }
}

export interface CreateProductData {
  name: string
  description?: string
  price: number
  sku: string
  category: string
  stock_quantity: number
  low_stock_threshold?: number
  active?: boolean
}

class ProductsService {
  async getProducts(filters: ProductFilters = {}): Promise<ProductResponse> {
    return apiService.get<ProductResponse>('/v1/products', filters)
  }

  async getProduct(id: number): Promise<Product> {
    return apiService.get<Product>(`/v1/products/${id}`)
  }

  async createProduct(data: CreateProductData | FormData): Promise<Product> {
    if (data instanceof FormData) {
      return this.postFormData<Product>('/v1/products', data)
    }
    return apiService.post<Product>('/v1/products', { product: data })
  }

  async updateProduct(id: number, data: Partial<CreateProductData> | FormData): Promise<Product> {
    if (data instanceof FormData) {
      return this.putFormData<Product>(`/v1/products/${id}`, data)
    }
    return apiService.put<Product>(`/v1/products/${id}`, { product: data })
  }

  private async postFormData<T>(url: string, formData: FormData): Promise<T> {
    const token = localStorage.getItem('auth_token')
    const headers: Record<string, string> = {}
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    console.log('Posting FormData to:', `http://localhost:3000/api${url}`)
    console.log('Headers:', headers)

    const response = await fetch(`http://localhost:3000/api${url}`, {
      method: 'POST',
      headers,
      body: formData
    })

    console.log('Response status:', response.status)
    console.log('Response headers:', Object.fromEntries(response.headers.entries()))

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Error response:', errorText)
      throw new Error(`HTTP error! status: ${response.status}, body: ${errorText}`)
    }

    const result = await response.json()
    console.log('Response data:', result)
    console.log('Image URL in response:', result.image_url)
    return result
  }

  private async putFormData<T>(url: string, formData: FormData): Promise<T> {
    const token = localStorage.getItem('auth_token')
    const headers: Record<string, string> = {}
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    console.log('Updating with FormData to:', `http://localhost:3000/api${url}`)
    console.log('Headers:', headers)

    const response = await fetch(`http://localhost:3000/api${url}`, {
      method: 'PATCH', // Use PATCH directly
      headers,
      body: formData
    })

    console.log('Update response status:', response.status)
    console.log('Update response headers:', Object.fromEntries(response.headers.entries()))

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Update error response:', errorText)
      throw new Error(`HTTP error! status: ${response.status}, body: ${errorText}`)
    }

    const result = await response.json()
    console.log('Update response data:', result)
    return result
  }

  async deleteProduct(id: number): Promise<{ message: string }> {
    return apiService.delete<{ message: string }>(`/v1/products/${id}`)
  }

  async getCategories(): Promise<string[]> {
    const response = await this.getProducts()
    const categories = new Set(response.products.map(p => p.category))
    return Array.from(categories).sort()
  }
}

export const productsService = new ProductsService()