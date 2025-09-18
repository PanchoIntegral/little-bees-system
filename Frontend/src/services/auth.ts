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
  two_factor_enabled?: boolean
  must_change_password?: boolean
  phone_number?: string
  phone_verified?: boolean
  sms_verification_enabled?: boolean
}

interface LoginResponse {
  success: boolean
  user?: User
  token?: string
  message?: string
  requires_two_factor?: boolean
  requires_password_change?: boolean
  user_id?: number
  verification_methods?: string[]
}

interface TwoFactorResponse {
  success: boolean
  message?: string
  user?: User
  token?: string
}

interface TwoFactorSetupResponse {
  success: boolean
  qr_code_uri?: string
  backup_codes?: string[]
  message?: string
}

interface TwoFactorStatusResponse {
  two_factor_enabled: boolean
  backup_codes_count: number
}

interface SmsVerificationResponse {
  success: boolean
  message?: string
  expires_in_minutes?: number
  phone_number?: string
  phone_verified?: boolean
  sms_verification_enabled?: boolean
  has_pending_code?: boolean
}

interface SmsSetupResponse {
  success: boolean
  message?: string
  phone_number?: string
  expires_in_minutes?: number
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
        // Check if 2FA or password change is required
        if (data.requires_two_factor) {
          return {
            success: true,
            requires_two_factor: true,
            user_id: data.user_id,
            verification_methods: data.verification_methods || ['totp'],
            message: data.message
          }
        }

        if (data.requires_password_change) {
          return {
            success: true,
            requires_password_change: true,
            user_id: data.user_id,
            message: data.message
          }
        }

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

  async logout(): Promise<void> {
    try {
      // Call logout endpoint if authenticated
      if (this.token.value) {
        await this.apiCall('/auth/logout', { method: 'POST' })
      }
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      this.token.value = null
      this.user.value = null
      localStorage.removeItem('auth_token')
      localStorage.removeItem('user')
    }
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

  // Two-Factor Authentication methods
  async verifyTwoFactor(userId: number, code: string, method: string = 'totp'): Promise<TwoFactorResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/auth/verify_two_factor`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ user_id: userId, code, method })
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
          message: data.message || '2FA verification failed'
        }
      }
    } catch (error) {
      console.error('2FA verification error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async changePassword(userId: number, currentPassword: string, newPassword: string): Promise<TwoFactorResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/auth/change_password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: userId,
          current_password: currentPassword,
          new_password: newPassword
        })
      })

      const data = await response.json()

      if (response.ok && data.success) {
        return {
          success: true,
          message: data.message
        }
      } else {
        return {
          success: false,
          message: data.message || 'Password change failed'
        }
      }
    } catch (error) {
      console.error('Password change error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async getTwoFactorStatus(): Promise<TwoFactorStatusResponse | null> {
    try {
      const response = await this.apiCall('/v1/two_factor')
      if (!response) return null

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Get 2FA status error:', error)
      return null
    }
  }

  async setupTwoFactor(): Promise<TwoFactorSetupResponse> {
    try {
      const response = await this.apiCall('/v1/two_factor/setup', { method: 'POST' })
      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Setup 2FA error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async enableTwoFactor(code: string): Promise<TwoFactorResponse> {
    try {
      const response = await this.apiCall('/v1/two_factor/enable', {
        method: 'POST',
        body: JSON.stringify({ code })
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()

      // Update user's 2FA status
      if (data.success && this.user.value) {
        this.user.value.two_factor_enabled = true
        localStorage.setItem('user', JSON.stringify(this.user.value))
      }

      return data
    } catch (error) {
      console.error('Enable 2FA error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async disableTwoFactor(code: string): Promise<TwoFactorResponse> {
    try {
      const response = await this.apiCall('/v1/two_factor/disable', {
        method: 'POST',
        body: JSON.stringify({ code })
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()

      // Update user's 2FA status
      if (data.success && this.user.value) {
        this.user.value.two_factor_enabled = false
        localStorage.setItem('user', JSON.stringify(this.user.value))
      }

      return data
    } catch (error) {
      console.error('Disable 2FA error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async regenerateBackupCodes(code: string): Promise<TwoFactorSetupResponse> {
    try {
      const response = await this.apiCall('/v1/two_factor/regenerate_backup_codes', {
        method: 'POST',
        body: JSON.stringify({ code })
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Regenerate backup codes error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async getQRCode(): Promise<{ qr_code_uri?: string } | null> {
    try {
      const response = await this.apiCall('/v1/two_factor/qr_code')
      if (!response) return null

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Get QR code error:', error)
      return null
    }
  }

  // SMS Verification methods
  async requestSmsCode(userId: number): Promise<SmsVerificationResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/auth/request_sms_code`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ user_id: userId })
      })

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Request SMS code error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async setupSmsVerification(phoneNumber: string): Promise<SmsSetupResponse> {
    try {
      const response = await this.apiCall('/v1/sms_verification/setup', {
        method: 'POST',
        body: JSON.stringify({ phone_number: phoneNumber })
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Setup SMS verification error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async sendSmsVerificationCode(): Promise<SmsVerificationResponse> {
    try {
      const response = await this.apiCall('/v1/sms_verification/send_code', {
        method: 'POST'
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Send SMS code error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async verifySmsCode(code: string): Promise<SmsVerificationResponse> {
    try {
      const response = await this.apiCall('/v1/sms_verification/verify_code', {
        method: 'POST',
        body: JSON.stringify({ code })
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()

      // Update user phone verification status
      if (data.success && this.user.value) {
        this.user.value.phone_verified = true
        localStorage.setItem('user', JSON.stringify(this.user.value))
      }

      return data
    } catch (error) {
      console.error('Verify SMS code error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async enableSmsVerification(): Promise<SmsVerificationResponse> {
    try {
      const response = await this.apiCall('/v1/sms_verification/enable', {
        method: 'POST'
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()

      // Update user SMS verification status
      if (data.success && this.user.value) {
        this.user.value.sms_verification_enabled = true
        localStorage.setItem('user', JSON.stringify(this.user.value))
      }

      return data
    } catch (error) {
      console.error('Enable SMS verification error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async disableSmsVerification(): Promise<SmsVerificationResponse> {
    try {
      const response = await this.apiCall('/v1/sms_verification/disable', {
        method: 'POST'
      })

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()

      // Update user SMS verification status
      if (data.success && this.user.value) {
        this.user.value.sms_verification_enabled = false
        localStorage.setItem('user', JSON.stringify(this.user.value))
      }

      return data
    } catch (error) {
      console.error('Disable SMS verification error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
  }

  async getSmsVerificationStatus(): Promise<SmsVerificationResponse> {
    try {
      const response = await this.apiCall('/v1/sms_verification/status')

      if (!response) {
        return { success: false, message: 'Authentication required' }
      }

      const data = await response.json()
      return { success: true, ...data }
    } catch (error) {
      console.error('Get SMS verification status error:', error)
      return {
        success: false,
        message: 'Network error occurred'
      }
    }
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




