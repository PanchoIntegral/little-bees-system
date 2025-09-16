<template>
  <div v-if="show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4 transform transition-all duration-200 scale-100">
      <!-- Header with Icon -->
      <div class="flex items-center mb-4">
        <div class="flex-shrink-0">
          <div class="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
            </svg>
          </div>
        </div>
        <div class="ml-4">
          <h3 class="text-lg font-medium text-gray-900">
            Confirmar cierre de sesión
          </h3>
          <p class="text-sm text-gray-500">
            ¿Estás seguro de que deseas cerrar sesión?
          </p>
        </div>
      </div>

      <!-- User Info Card -->
      <div class="bg-gray-50 p-4 rounded-lg mb-6" v-if="user">
        <div class="flex items-center space-x-3">
          <div class="flex-shrink-0">
            <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
              </svg>
            </div>
          </div>
          <div>
            <p class="text-sm font-medium text-gray-900">
              {{ user.full_name }}
            </p>
            <p class="text-xs text-gray-500">
              {{ user.email }}
            </p>
            <div class="flex items-center mt-1">
              <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                {{ user.role }}
              </span>
              <span v-if="user.two_factor_enabled" class="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                </svg>
                2FA Activo
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Info Section -->
      <div class="text-sm text-gray-600 mb-6">
        <div class="flex items-start space-x-3">
          <svg class="w-5 h-5 text-blue-500 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <div>
            <p class="font-medium text-gray-700 mb-2">Antes de cerrar sesión:</p>
            <ul class="text-gray-600 space-y-1">
              <li class="flex items-center">
                <svg class="w-3 h-3 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                </svg>
                Guarda cualquier trabajo pendiente
              </li>
              <li class="flex items-center">
                <svg class="w-3 h-3 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                </svg>
                Tus datos permanecerán seguros
              </li>
              <li class="flex items-center">
                <svg class="w-3 h-3 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                </svg>
                Podrás iniciar sesión nuevamente cuando quieras
              </li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="flex space-x-3">
        <button
          @click="$emit('cancel')"
          class="flex-1 bg-gray-100 text-gray-700 py-3 px-4 rounded-lg text-sm font-medium hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200"
        >
          <span class="flex items-center justify-center">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
            Cancelar
          </span>
        </button>
        <button
          @click="$emit('confirm')"
          :disabled="isLoading"
          class="flex-1 bg-red-600 text-white py-3 px-4 rounded-lg text-sm font-medium hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="!isLoading" class="flex items-center justify-center">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
            </svg>
            Cerrar Sesión
          </span>
          <span v-else class="flex items-center justify-center">
            <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Cerrando sesión...
          </span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface User {
  id: number
  email: string
  first_name: string
  last_name: string
  full_name: string
  role: string
  two_factor_enabled?: boolean
}

interface Props {
  show: boolean
  user?: User | null
  isLoading?: boolean
}

defineProps<Props>()

defineEmits<{
  cancel: []
  confirm: []
}>()
</script>