// Authentication service for Little Bee's POS
import { ref, computed, type Ref } from 'vue'

const API_BASE_URL = 'http://localhost:3000/api'

interface User {
  id: number
  email: string
  first_name: string
  last_name: string
  full_name: string
  role: string
}

interface LoginResponse {
  success: boolean
  user?: User
  token?: string
  message?: string
}

class AuthService {
  public token: Ref<string | null>
  public user: Ref<User | null>

  constructor() {
    this.token = ref(localStorage.getItem('auth_token'))
    this.user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  }

  async login(email: string, password: string): Promise<LoginResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password })
      })

      const data = await response.json()

      if (response.ok && data.success) {
        // Store authentication data
        this.token.value = data.token
        this.user.value = data.user

        localStorage.setItem('auth_token', data.token)
        localStorage.setItem('user', JSON.stringify(data.user))

        return {
          success: true,
          user: data.user,
          token: data.token
        }
      } else {
        return {
          success: false,
          message: data.message || 'Login failed'
        }
      }
    } catch (error) {
      console.error('Login error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  logout(): void {
    this.token.value = null
    this.user.value = null
    localStorage.removeItem('auth_token')
    localStorage.removeItem('user')
  }

  isAuthenticated(): boolean {
    if (!this.token.value || !this.user.value) {
      return false
    }

    // Check if token exists and is not expired
    try {
      // For JWT tokens, we can decode and check expiration
      // If it's a simple token, just check if it exists
      return true
    } catch (error) {
      console.error('Token validation error:', error)
      this.logout()
      return false
    }
  }

  getUser(): User | null {
    return this.user.value
  }

  getToken(): string | null {
    return this.token.value
  }

  // Reactive getters for Vue components
  get currentUser(): Ref<User | null> {
    return this.user
  }

  get isLoggedIn() {
    return computed(() => !!this.token.value && !!this.user.value)
  }

  // Helper method for making authenticated API calls
  async apiCall(endpoint: string, options: RequestInit = {}): Promise<Response | null> {
    const defaultHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
    }

    if (this.token.value) {
      defaultHeaders['Authorization'] = `Bearer ${this.token.value}`
    }

    const config: RequestInit = {
      ...options,
      headers: {
        ...defaultHeaders,
        ...options.headers
      }
    }

    try {
      const response = await fetch(`${API_BASE_URL}${endpoint}`, config)

      // Only logout if we were authenticated and got 401 on a protected route
      if (response.status === 401 && this.isAuthenticated() && !endpoint.includes('/auth/')) {
        console.log('Authentication expired, logging out...')
        this.logout()
        window.location.href = '/login'
        return null
      }

      return response
    } catch (error) {
      console.error('API call error:', error)
      throw error
    }
  }
}

// Export a singleton instance
export const authService = new AuthService()


