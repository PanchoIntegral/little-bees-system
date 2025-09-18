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
              <h1 class="text-2xl font-bold text-gray-900">⚙️ Configuración</h1>
              <p class="text-sm text-gray-600">Gestiona tu cuenta y preferencias de seguridad</p>
            </div>
          </div>
          <div class="flex items-center space-x-3">
            <span class="text-sm text-gray-500">
              Última actualización: {{ formatDate(new Date()) }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Settings Navigation -->
      <div class="mb-8">
        <nav class="flex space-x-8">
          <button
            @click="activeTab = 'profile'"
            :class="[
              'px-3 py-2 text-sm font-medium transition-colors',
              activeTab === 'profile'
                ? 'text-blue-600 border-b-2 border-blue-600'
                : 'text-gray-500 hover:text-gray-700'
            ]"
          >
            👤 Perfil
          </button>
          <button
            @click="activeTab = 'security'"
            :class="[
              'px-3 py-2 text-sm font-medium transition-colors',
              activeTab === 'security'
                ? 'text-blue-600 border-b-2 border-blue-600'
                : 'text-gray-500 hover:text-gray-700'
            ]"
          >
            🔒 Seguridad
          </button>
        </nav>
      </div>

      <!-- Profile Tab -->
      <div v-if="activeTab === 'profile'" class="space-y-6">
        <!-- User Information Card -->
        <div class="bg-white rounded-lg shadow-lg p-6">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-lg font-medium text-gray-900">Información Personal</h2>
            <button
              @click="editMode = !editMode"
              class="text-blue-600 hover:text-blue-700 text-sm font-medium"
            >
              {{ editMode ? 'Cancelar' : 'Editar' }}
            </button>
          </div>

          <div v-if="user" class="space-y-6">
            <!-- Avatar Section -->
            <div class="flex items-center space-x-6">
              <div class="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
                <span class="text-2xl font-bold text-white">
                  {{ user.first_name?.[0] }}{{ user.last_name?.[0] }}
                </span>
              </div>
              <div>
                <h3 class="text-xl font-medium text-gray-900">{{ user.full_name }}</h3>
                <p class="text-gray-600">{{ user.email }}</p>
                <div class="flex items-center mt-2 space-x-2">
                  <span :class="[
                    'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                    user.role === 'admin' ? 'bg-red-100 text-red-800' :
                    user.role === 'manager' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-green-100 text-green-800'
                  ]">
                    {{ user.role === 'admin' ? '👑 Administrador' :
                       user.role === 'manager' ? '👨‍💼 Gerente' : '👤 Empleado' }}
                  </span>
                  <span v-if="user.two_factor_enabled"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    🔐 2FA Activo
                  </span>
                </div>
              </div>
            </div>

            <!-- Editable Fields -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Nombre</label>
                <input
                  v-if="editMode"
                  v-model="editData.first_name"
                  type="text"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
                <p v-else class="text-gray-900 py-2">{{ user.first_name }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Apellido</label>
                <input
                  v-if="editMode"
                  v-model="editData.last_name"
                  type="text"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
                <p v-else class="text-gray-900 py-2">{{ user.last_name }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <p class="text-gray-900 py-2">{{ user.email }}</p>
                <p class="text-xs text-gray-500">El email no puede modificarse</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Rol</label>
                <p class="text-gray-900 py-2">{{ user.role }}</p>
                <p class="text-xs text-gray-500">Solo administradores pueden cambiar roles</p>
              </div>
            </div>

            <!-- Save Button -->
            <div v-if="editMode" class="flex justify-end space-x-3">
              <button
                @click="editMode = false"
                class="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 transition-colors"
              >
                Cancelar
              </button>
              <button
                @click="saveProfile"
                :disabled="isSaving"
                class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50"
              >
                {{ isSaving ? 'Guardando...' : 'Guardar Cambios' }}
              </button>
            </div>
          </div>
        </div>

      </div>

      <!-- Security Tab -->
      <div v-if="activeTab === 'security'" class="space-y-6">

        <!-- Two-Factor Authentication Section -->
        <TwoFactorSetup />

        <!-- Security Log -->
        <div class="bg-white rounded-lg shadow-lg p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-4">📋 Registro de Seguridad</h3>
          <div class="space-y-3">
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                  <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">Inicio de sesión exitoso</p>
                  <p class="text-xs text-gray-500">Hoy a las {{ formatTime(new Date()) }}</p>
                </div>
              </div>
              <span class="text-xs text-gray-400">IP: 192.168.1.100</span>
            </div>

            <div v-if="user?.two_factor_enabled" class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">Autenticación de dos factores activada</p>
                  <p class="text-xs text-gray-500">Configurado anteriormente</p>
                </div>
              </div>
              <span class="text-xs text-green-600 font-medium">Activo</span>
            </div>
          </div>
        </div>
      </div>


      <!-- Logout Section (Always Visible) -->
      <div class="bg-white rounded-lg shadow-lg p-6 border-l-4 border-red-500">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="text-lg font-medium text-gray-900">🚪 Cerrar Sesión</h3>
            <p class="text-sm text-gray-600">Cierra tu sesión de forma segura</p>
          </div>
          <button
            @click="showLogoutDialog"
            class="bg-red-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-red-700 transition-colors"
          >
            <svg class="w-4 h-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
            </svg>
            Cerrar Sesión
          </button>
        </div>
      </div>
    </div>

    <!-- Logout Modal -->
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

// Tab management
const activeTab = ref('security') // Empezamos en la pestaña de seguridad

// Edit mode for profile
const editMode = ref(false)
const editData = ref({
  first_name: '',
  last_name: ''
})
const isSaving = ref(false)

// Password form
const passwordForm = ref({
  current: '',
  new: ''
})
const isPasswordLoading = ref(false)
const passwordMessage = ref<{ type: 'success' | 'error', text: string } | null>(null)

// Preferences
const selectedTheme = ref('light')
const selectedLanguage = ref('es')
const notifications = ref({
  email: true,
  browser: true,
  security: true
})
const isSavingPreferences = ref(false)

// Themes
const themes = [
  { id: 'light', name: 'Claro', icon: '☀️' },
  { id: 'dark', name: 'Oscuro', icon: '🌙' },
  { id: 'auto', name: 'Auto', icon: '🔄' }
]

// Account stats
const accountStats = ref({
  days_active: 45,
  last_login: 'Hoy',
  security_score: user.value?.two_factor_enabled ? '95%' : '75%'
})

// Logout functionality
const {
  showLogoutModal,
  isLoggingOut,
  showLogoutDialog,
  cancelLogout,
  confirmLogout
} = useLogout()

// Password validation
const isValidPassword = computed(() => {
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/
  return passwordRegex.test(passwordForm.value.new)
})

// Methods
const handlePasswordChange = async () => {
  if (!passwordForm.value.current || !passwordForm.value.new || !user.value) {
    passwordMessage.value = { type: 'error', text: 'Por favor completa todos los campos' }
    return
  }

  if (!isValidPassword.value) {
    passwordMessage.value = { type: 'error', text: 'La contraseña no cumple con los requisitos' }
    return
  }

  isPasswordLoading.value = true
  passwordMessage.value = null

  try {
    const result = await authService.changePassword(user.value.id, passwordForm.value.current, passwordForm.value.new)

    if (result.success) {
      passwordMessage.value = { type: 'success', text: 'Contraseña cambiada exitosamente' }
      passwordForm.value.current = ''
      passwordForm.value.new = ''
    } else {
      passwordMessage.value = { type: 'error', text: result.message || 'Error al cambiar la contraseña' }
    }
  } catch (error) {
    console.error('Password change error:', error)
    passwordMessage.value = { type: 'error', text: 'Error inesperado al cambiar la contraseña' }
  } finally {
    isPasswordLoading.value = false
  }
}

const saveProfile = async () => {
  // Aquí implementarías la lógica para guardar el perfil
  isSaving.value = true
  await new Promise(resolve => setTimeout(resolve, 1000)) // Simular API call
  isSaving.value = false
  editMode.value = false
}

const savePreferences = async () => {
  isSavingPreferences.value = true
  // Aquí implementarías la lógica para guardar preferencias
  await new Promise(resolve => setTimeout(resolve, 1000)) // Simular API call
  isSavingPreferences.value = false
}

const formatDate = (date: Date) => {
  return date.toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const formatTime = (date: Date) => {
  return date.toLocaleTimeString('es-ES', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  if (user.value) {
    editData.value = {
      first_name: user.value.first_name,
      last_name: user.value.last_name
    }
  }
})
</script>