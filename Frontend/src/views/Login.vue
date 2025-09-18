<template>
  <div class="min-h-screen bg-gradient-to-br from-amber-50 via-white to-orange-50 flex items-center justify-center p-4">
    <div class="w-full max-w-sm">
      <!-- Logo Section -->
      <div class="text-center mb-12">
        <div class="inline-flex items-center justify-center mb-6">
          <Logo :size="48" :show-text="false" variant="icon" class="text-amber-500" />
        </div>
        <h1 class="text-2xl font-light text-gray-900 mb-2" style="font-family: 'Inter', -apple-system, sans-serif;">
          Bienvenido de vuelta
        </h1>
        <p class="text-sm text-gray-500">Inicia sesión en Little Bee's POS</p>
      </div>

      <!-- Login Form -->
      <form v-if="!showTwoFactor && !showPasswordChange" @submit.prevent="handleLogin" class="space-y-6">
        <div class="space-y-4">
          <div>
            <input
              id="email"
              v-model="email"
              type="email"
              autocomplete="email"
              required
              class="w-full px-4 py-4 bg-white border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:border-amber-300 focus:ring-2 focus:ring-amber-100 focus:outline-none transition-all duration-200"
              placeholder="Dirección de email"
            />
          </div>

          <div class="relative">
            <input
              id="password"
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              autocomplete="current-password"
              required
              class="w-full px-4 py-4 bg-white border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:border-amber-300 focus:ring-2 focus:ring-amber-100 focus:outline-none transition-all duration-200 pr-12"
              placeholder="Contraseña"
            />
            <button
              type="button"
              @click="showPassword = !showPassword"
              class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg v-if="showPassword" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21"></path>
              </svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
              </svg>
            </button>
          </div>
        </div>

        <div class="flex items-center justify-between text-sm">
          <label class="flex items-center">
            <input type="checkbox" class="w-4 h-4 text-amber-500 border-gray-300 rounded focus:ring-amber-200 focus:ring-2">
            <span class="ml-2 text-gray-600">Remember me</span>
          </label>
          <a href="#" class="text-amber-600 hover:text-amber-700 font-medium transition-colors">
            Forgot password?
          </a>
        </div>

        <!-- Error Message -->
        <div v-if="errorMessage" class="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600 text-center">{{ errorMessage }}</p>
        </div>

        <button
          type="submit"
          :disabled="isLoading"
          class="w-full bg-gray-900 text-white py-4 px-4 rounded-xl font-medium hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="!isLoading">Sign in</span>
          <div v-else class="flex items-center justify-center">
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Signing in...
          </div>
        </button>
      </form>

      <!-- Two-Factor Authentication Form -->
      <form v-if="showTwoFactor" @submit.prevent="handleTwoFactor" class="space-y-6">
        <div class="text-center mb-6">
          <h2 class="text-lg font-medium text-gray-900 mb-2">Two-Factor Authentication</h2>
          <p class="text-sm text-gray-600">
            {{ selectedMethod === 'sms' ? 'Enter the verification code sent to your phone' : 'Enter the verification code from your authenticator app' }}
          </p>
        </div>

        <!-- Method Selection (if multiple methods available) -->
        <div v-if="verificationMethods.length > 1" class="space-y-3">
          <p class="text-sm font-medium text-gray-700">Choose verification method:</p>
          <div class="grid grid-cols-2 gap-3">
            <button
              v-for="method in verificationMethods"
              :key="method"
              type="button"
              @click="selectedMethod = method"
              :class="[
                'flex items-center justify-center px-4 py-3 rounded-lg border-2 text-sm font-medium transition-all duration-200',
                selectedMethod === method
                  ? 'border-amber-500 bg-amber-50 text-amber-700'
                  : 'border-gray-200 bg-white text-gray-600 hover:border-gray-300'
              ]"
            >
              <svg v-if="method === 'totp'" class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
              </svg>
              <svg v-if="method === 'sms'" class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>
              </svg>
              {{ method === 'totp' ? 'Authenticator' : 'SMS' }}
            </button>
          </div>
        </div>

        <!-- SMS Code Request Button -->
        <div v-if="selectedMethod === 'sms'" class="text-center">
          <button
            type="button"
            @click="requestSmsCode"
            :disabled="isSendingSms"
            class="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <svg v-if="!isSendingSms" class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>
            </svg>
            <svg v-else class="animate-spin w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            {{ isSendingSms ? 'Sending...' : 'Send SMS Code' }}
          </button>
        </div>

        <div>
          <input
            id="twoFactorCode"
            v-model="twoFactorCode"
            type="text"
            inputmode="numeric"
            pattern="[0-9]*"
            maxlength="6"
            required
            class="w-full px-4 py-4 bg-white border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:border-amber-300 focus:ring-2 focus:ring-amber-100 focus:outline-none transition-all duration-200 text-center text-xl tracking-widest"
            placeholder="000000"
          />
        </div>

        <div class="flex space-x-3">
          <button
            type="button"
            @click="backToLogin"
            class="flex-1 bg-gray-100 text-gray-700 py-4 px-4 rounded-xl font-medium hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200"
          >
            Back
          </button>
          <button
            type="submit"
            :disabled="isLoading || twoFactorCode.length !== 6"
            class="flex-1 bg-gray-900 text-white py-4 px-4 rounded-xl font-medium hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="!isLoading">Verify</span>
            <div v-else class="flex items-center justify-center">
              <svg class="animate-spin -ml-1 mr-3 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Verifying...
            </div>
          </button>
        </div>

        <p class="text-xs text-gray-500 text-center">
          {{ selectedMethod === 'sms' ? 'Code will be sent to your registered phone number' : 'Lost your authenticator? Use one of your backup codes instead' }}
        </p>
      </form>

      <!-- Password Change Form -->
      <form v-if="showPasswordChange" @submit.prevent="handlePasswordChange" class="space-y-6">
        <div class="text-center mb-6">
          <h2 class="text-lg font-medium text-gray-900 mb-2">Password Change Required</h2>
          <p class="text-sm text-gray-600">Your password has expired. Please set a new password.</p>
        </div>

        <div class="space-y-4">
          <div class="relative">
            <input
              id="currentPassword"
              v-model="currentPassword"
              :type="showCurrentPassword ? 'text' : 'password'"
              required
              class="w-full px-4 py-4 bg-white border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:border-amber-300 focus:ring-2 focus:ring-amber-100 focus:outline-none transition-all duration-200 pr-12"
              placeholder="Current password"
            />
            <button
              type="button"
              @click="showCurrentPassword = !showCurrentPassword"
              class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg v-if="showCurrentPassword" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21"></path>
              </svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
              </svg>
            </button>
          </div>

          <div class="relative">
            <input
              id="newPassword"
              v-model="newPassword"
              :type="showNewPassword ? 'text' : 'password'"
              required
              class="w-full px-4 py-4 bg-white border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:border-amber-300 focus:ring-2 focus:ring-amber-100 focus:outline-none transition-all duration-200 pr-12"
              placeholder="New password"
            />
            <button
              type="button"
              @click="showNewPassword = !showNewPassword"
              class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg v-if="showNewPassword" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21"></path>
              </svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
              </svg>
            </button>
          </div>

          <div class="text-xs text-gray-500 space-y-1">
            <p>Password must include:</p>
            <ul class="list-disc list-inside space-y-1 ml-2">
              <li>At least 8 characters</li>
              <li>One uppercase letter</li>
              <li>One lowercase letter</li>
              <li>One number</li>
              <li>One special character (@$!%*?&)</li>
            </ul>
          </div>
        </div>

        <button
          type="submit"
          :disabled="isLoading || !isValidPassword"
          class="w-full bg-gray-900 text-white py-4 px-4 rounded-xl font-medium hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="!isLoading">Change Password</span>
          <div v-else class="flex items-center justify-center">
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Changing...
          </div>
        </button>
      </form>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import Logo from '../components/Logo.vue'
import { authService } from '../services/auth'

const router = useRouter()
const email = ref('')
const password = ref('')
const showPassword = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')

// Two-Factor Authentication
const showTwoFactor = ref(false)
const twoFactorCode = ref('')
const userId = ref<number | null>(null)
const verificationMethods = ref<string[]>([])
const selectedMethod = ref('totp')
const isSendingSms = ref(false)

// Password Change
const showPasswordChange = ref(false)
const currentPassword = ref('')
const newPassword = ref('')
const showCurrentPassword = ref(false)
const showNewPassword = ref(false)

// Computed property for password validation
const isValidPassword = computed(() => {
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/
  return passwordRegex.test(newPassword.value)
})

const handleLogin = async () => {
  if (!email.value || !password.value) {
    errorMessage.value = 'Please enter both email and password'
    return
  }

  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await authService.login(email.value, password.value)

    if (result.success) {
      if (result.requires_two_factor) {
        userId.value = result.user_id || null
        verificationMethods.value = result.verification_methods || ['totp']
        selectedMethod.value = verificationMethods.value[0] || 'totp'
        showTwoFactor.value = true
        errorMessage.value = ''
      } else if (result.requires_password_change) {
        userId.value = result.user_id || null
        currentPassword.value = password.value
        showPasswordChange.value = true
        errorMessage.value = ''
      } else {
        console.log('Login successful:', result.user)
        router.push('/')
      }
    } else {
      errorMessage.value = result.message || 'Login failed'
    }
  } catch (error) {
    console.error('Login failed:', error)
    errorMessage.value = 'An unexpected error occurred'
  } finally {
    isLoading.value = false
  }
}

const handleTwoFactor = async () => {
  if (!twoFactorCode.value || !userId.value) {
    errorMessage.value = 'Please enter the verification code'
    return
  }

  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await authService.verifyTwoFactor(userId.value, twoFactorCode.value, selectedMethod.value)

    if (result.success) {
      console.log('2FA verification successful:', result.user)
      router.push('/')
    } else {
      errorMessage.value = result.message || '2FA verification failed'
      twoFactorCode.value = ''
    }
  } catch (error) {
    console.error('2FA verification failed:', error)
    errorMessage.value = 'An unexpected error occurred'
  } finally {
    isLoading.value = false
  }
}

const handlePasswordChange = async () => {
  if (!currentPassword.value || !newPassword.value || !userId.value) {
    errorMessage.value = 'Please fill in all password fields'
    return
  }

  if (!isValidPassword.value) {
    errorMessage.value = 'Password does not meet requirements'
    return
  }

  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await authService.changePassword(userId.value, currentPassword.value, newPassword.value)

    if (result.success) {
      // After successful password change, redirect to login
      showPasswordChange.value = false
      currentPassword.value = ''
      newPassword.value = ''
      userId.value = null
      errorMessage.value = ''
      // Show success message briefly
      setTimeout(() => {
        errorMessage.value = 'Password changed successfully. Please log in again.'
      }, 100)
    } else {
      errorMessage.value = result.message || 'Password change failed'
    }
  } catch (error) {
    console.error('Password change failed:', error)
    errorMessage.value = 'An unexpected error occurred'
  } finally {
    isLoading.value = false
  }
}

const requestSmsCode = async () => {
  if (!userId.value) {
    errorMessage.value = 'Session expired. Please log in again.'
    return
  }

  isSendingSms.value = true
  errorMessage.value = ''

  try {
    const result = await authService.requestSmsCode(userId.value)

    if (result.success) {
      errorMessage.value = ''
      // Show a brief success message
      const originalMessage = errorMessage.value
      errorMessage.value = 'SMS code sent! Check your phone.'

      // In development, also fetch the actual code for debugging
      if (import.meta.env.DEV) {
        try {
          // Make a call to get current SMS code for debugging
          const response = await fetch('http://localhost:3000/api/debug/sms_code', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId.value })
          })
          if (response.ok) {
            const debugData = await response.json()
            console.log('🐛 DEBUG - SMS Code:', debugData.code)
            errorMessage.value = `SMS sent! Debug Code: ${debugData.code}`
          }
        } catch (debugError) {
          console.log('Debug endpoint not available')
        }
      }

      setTimeout(() => {
        errorMessage.value = originalMessage
      }, 5000)
    } else {
      errorMessage.value = result.message || 'Failed to send SMS code'
    }
  } catch (error) {
    console.error('SMS request failed:', error)
    errorMessage.value = 'Failed to send SMS code'
  } finally {
    isSendingSms.value = false
  }
}

const backToLogin = () => {
  showTwoFactor.value = false
  showPasswordChange.value = false
  twoFactorCode.value = ''
  currentPassword.value = ''
  newPassword.value = ''
  userId.value = null
  verificationMethods.value = []
  selectedMethod.value = 'totp'
  errorMessage.value = ''
}
</script>