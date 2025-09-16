<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-6">
          <div class="flex items-center space-x-4">
            <button
              @click="$router.back()"
              class="p-2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
              </svg>
            </button>
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Profile & Security</h1>
              <p class="text-sm text-gray-600">Manage your account settings and security preferences</p>
            </div>
          </div>
          <button
            @click="showLogoutDialog"
            class="bg-gray-900 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-gray-800 transition-colors"
          >
            <svg class="w-4 h-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
            </svg>
            Cerrar Sesión
          </button>
        </div>
      </div>
    </div>

    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="space-y-8">
        <!-- User Information -->
        <div class="bg-white rounded-lg shadow-lg p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-4">Account Information</h2>
          <div v-if="user" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">First Name</label>
                <p class="text-gray-900">{{ user.first_name }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Last Name</label>
                <p class="text-gray-900">{{ user.last_name }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <p class="text-gray-900">{{ user.email }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {{ user.role }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Password Change -->
        <div class="bg-white rounded-lg shadow-lg p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-4">Change Password</h2>
          <p class="text-sm text-gray-600 mb-6">
            It's a good idea to use a strong password that you don't use elsewhere.
          </p>

          <form @submit.prevent="handlePasswordChange" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label for="currentPassword" class="block text-sm font-medium text-gray-700 mb-1">
                  Current Password
                </label>
                <input
                  id="currentPassword"
                  v-model="currentPassword"
                  type="password"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="newPassword" class="block text-sm font-medium text-gray-700 mb-1">
                  New Password
                </label>
                <input
                  id="newPassword"
                  v-model="newPassword"
                  type="password"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
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

            <div v-if="passwordErrorMessage" class="p-3 bg-red-50 border border-red-200 rounded-md">
              <p class="text-sm text-red-600">{{ passwordErrorMessage }}</p>
            </div>

            <div v-if="passwordSuccessMessage" class="p-3 bg-green-50 border border-green-200 rounded-md">
              <p class="text-sm text-green-600">{{ passwordSuccessMessage }}</p>
            </div>

            <div class="flex justify-end">
              <button
                type="submit"
                :disabled="isPasswordLoading || !isValidPassword"
                class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span v-if="!isPasswordLoading">Change Password</span>
                <span v-else class="flex items-center">
                  <svg class="animate-spin -ml-1 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Changing...
                </span>
              </button>
            </div>
          </form>
        </div>

        <!-- Two-Factor Authentication -->
        <TwoFactorSetup />
      </div>
    </div>

    <!-- Logout Confirmation Modal -->
    <LogoutModal
      :show="showLogoutModal"
      :user="user"
      :is-loading="isLoggingOut"
      @cancel="cancelLogout"
      @confirm="confirmLogout"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { authService } from '../services/auth'
import { useLogout } from '../composables/useLogout'
import TwoFactorSetup from '../components/TwoFactorSetup.vue'
import LogoutModal from '../components/LogoutModal.vue'

// User data
const user = computed(() => authService.getUser())

// Logout functionality
const {
  showLogoutModal,
  isLoggingOut,
  showLogoutDialog,
  cancelLogout,
  confirmLogout
} = useLogout()

// Password change
const currentPassword = ref('')
const newPassword = ref('')
const isPasswordLoading = ref(false)
const passwordErrorMessage = ref('')
const passwordSuccessMessage = ref('')


// Computed property for password validation
const isValidPassword = computed(() => {
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/
  return passwordRegex.test(newPassword.value)
})

const handlePasswordChange = async () => {
  if (!currentPassword.value || !newPassword.value) {
    passwordErrorMessage.value = 'Please fill in all password fields'
    return
  }

  if (!isValidPassword.value) {
    passwordErrorMessage.value = 'Password does not meet requirements'
    return
  }

  if (!user.value) {
    passwordErrorMessage.value = 'User not found'
    return
  }

  isPasswordLoading.value = true
  passwordErrorMessage.value = ''
  passwordSuccessMessage.value = ''

  try {
    const result = await authService.changePassword(user.value.id, currentPassword.value, newPassword.value)

    if (result.success) {
      passwordSuccessMessage.value = 'Password changed successfully'
      currentPassword.value = ''
      newPassword.value = ''
    } else {
      passwordErrorMessage.value = result.message || 'Password change failed'
    }
  } catch (error) {
    console.error('Password change failed:', error)
    passwordErrorMessage.value = 'An unexpected error occurred'
  } finally {
    isPasswordLoading.value = false
  }
}


onMounted(() => {
  // Clear any previous messages when component mounts
  passwordErrorMessage.value = ''
  passwordSuccessMessage.value = ''
})
</script>