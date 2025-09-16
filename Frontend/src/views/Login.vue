<template>
  <div class="min-h-screen bg-gradient-to-br from-amber-50 via-white to-orange-50 flex items-center justify-center p-4">
    <div class="w-full max-w-sm">
      <!-- Logo Section -->
      <div class="text-center mb-12">
        <div class="inline-flex items-center justify-center mb-6">
          <Logo :size="48" :show-text="false" variant="icon" class="text-amber-500" />
        </div>
        <h1 class="text-2xl font-light text-gray-900 mb-2" style="font-family: 'Inter', -apple-system, sans-serif;">
          Welcome back
        </h1>
        <p class="text-sm text-gray-500">Sign in to Little Bee's POS</p>
      </div>

      <!-- Login Form -->
      <form @submit.prevent="handleLogin" class="space-y-6">
        <div class="space-y-4">
          <div>
            <input
              id="email"
              v-model="email"
              type="email"
              autocomplete="email"
              required
              class="w-full px-4 py-4 bg-white border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:border-amber-300 focus:ring-2 focus:ring-amber-100 focus:outline-none transition-all duration-200"
              placeholder="Email address"
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
              placeholder="Password"
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

      <!-- Demo Credentials -->
      <div class="mt-8 p-4 bg-amber-50 border border-amber-100 rounded-xl">
        <div class="text-center">
          <p class="text-xs font-medium text-amber-800 mb-2">Demo Account</p>
          <div class="text-xs text-amber-700 space-y-1">
            <p><span class="font-medium">Email:</span> admin@littlebees.com</p>
            <p><span class="font-medium">Password:</span> admin123</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import Logo from '../components/Logo.vue'
import { authService } from '../services/auth'

const router = useRouter()
const email = ref('')
const password = ref('')
const showPassword = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')

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
      console.log('Login successful:', result.user)
      router.push('/')
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
</script>