<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center p-4"
    @click.self="cancel"
  >
    <div class="relative bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-medium text-gray-900">
            ✏️ Editar Empleado
          </h3>
          <button
            @click="cancel"
            class="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="p-6 space-y-4">
        <!-- Avatar y básicos -->
        <div class="flex items-center space-x-4 mb-6">
          <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
            <span class="text-xl font-bold text-white">
              {{ (form.first_name?.[0] || '') + (form.last_name?.[0] || '') }}
            </span>
          </div>
          <div>
            <h4 class="font-medium text-gray-900">{{ form.first_name }} {{ form.last_name }}</h4>
            <p class="text-sm text-gray-600">{{ form.email }}</p>
          </div>
        </div>

        <!-- Nombres -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Nombre</label>
            <input
              v-model="form.first_name"
              type="text"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              placeholder="Nombre"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Apellido</label>
            <input
              v-model="form.last_name"
              type="text"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              placeholder="Apellido"
            />
          </div>
        </div>

        <!-- Email (readonly) -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
          <input
            :value="form.email"
            type="email"
            readonly
            class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50 text-gray-500"
          />
          <p class="text-xs text-gray-500 mt-1">El email no puede modificarse</p>
        </div>

        <!-- Teléfono -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Teléfono</label>
          <input
            v-model="form.phone"
            type="tel"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            placeholder="Teléfono (opcional)"
          />
        </div>

        <!-- Rol -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Rol</label>
          <select
            v-model="form.role"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="employee">👤 Empleado</option>
            <option value="manager">👨‍💼 Manager</option>
            <option value="admin">👑 Administrador</option>
          </select>
        </div>

        <!-- Estado activo -->
        <div class="flex items-center space-x-3">
          <input
            v-model="form.active"
            type="checkbox"
            :id="`active-${employee?.id}`"
            class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
          />
          <label :for="`active-${employee?.id}`" class="text-sm font-medium text-gray-700">
            Usuario activo
          </label>
        </div>

        <!-- Información adicional -->
        <div class="bg-gray-50 rounded-lg p-4 space-y-2">
          <h4 class="text-sm font-medium text-gray-900">Información adicional</h4>
          <div class="grid grid-cols-2 gap-4 text-xs text-gray-600">
            <div>
              <span class="font-medium">Logins totales:</span>
              {{ employee?.sign_in_count || 0 }}
            </div>
            <div>
              <span class="font-medium">2FA:</span>
              {{ employee?.two_factor_enabled ? '✅ Activo' : '❌ Inactivo' }}
            </div>
            <div>
              <span class="font-medium">Teléfono verificado:</span>
              {{ employee?.phone_verified ? '✅ Sí' : '❌ No' }}
            </div>
            <div>
              <span class="font-medium">Último login:</span>
              {{ employee?.last_sign_in_at ? formatDate(employee.last_sign_in_at) : 'Nunca' }}
            </div>
          </div>
        </div>

        <!-- Error message -->
        <div v-if="errorMessage" class="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ errorMessage }}</p>
        </div>

        <!-- Success message -->
        <div v-if="successMessage" class="p-3 bg-green-50 border border-green-200 rounded-lg">
          <p class="text-sm text-green-600">{{ successMessage }}</p>
        </div>

        <!-- Buttons -->
        <div class="flex space-x-3 pt-4">
          <button
            type="button"
            @click="cancel"
            class="flex-1 bg-gray-100 text-gray-700 py-2 px-4 rounded-md hover:bg-gray-200 transition-colors font-medium"
          >
            Cancelar
          </button>
          <button
            type="submit"
            :disabled="isLoading"
            class="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="!isLoading">Guardar Cambios</span>
            <div v-else class="flex items-center justify-center">
              <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Guardando...
            </div>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'

interface Employee {
  id: number
  first_name: string
  last_name: string
  full_name: string
  email: string
  phone?: string
  role: string
  active: boolean
  two_factor_enabled: boolean
  phone_verified?: boolean
  sign_in_count?: number
  last_sign_in_at?: string
}

interface Props {
  show: boolean
  employee: Employee | null
  isLoading?: boolean
}

interface Emits {
  (e: 'cancel'): void
  (e: 'save', data: Partial<Employee>): void
}

const props = withDefaults(defineProps<Props>(), {
  isLoading: false
})

const emit = defineEmits<Emits>()

const form = ref({
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  role: 'employee',
  active: true
})

const errorMessage = ref('')
const successMessage = ref('')

// Watch for employee changes to populate form
watch(() => props.employee, (newEmployee) => {
  if (newEmployee) {
    form.value = {
      first_name: newEmployee.first_name || '',
      last_name: newEmployee.last_name || '',
      email: newEmployee.email || '',
      phone: newEmployee.phone || '',
      role: newEmployee.role || 'employee',
      active: newEmployee.active !== false
    }
  }
  errorMessage.value = ''
  successMessage.value = ''
}, { immediate: true })

const handleSubmit = () => {
  if (!props.employee) return

  errorMessage.value = ''
  successMessage.value = ''

  if (!form.value.first_name.trim() || !form.value.last_name.trim()) {
    errorMessage.value = 'Nombre y apellido son requeridos'
    return
  }

  // Only send changed fields
  const updateData: Partial<Employee> = {}

  if (form.value.first_name !== props.employee.first_name) {
    updateData.first_name = form.value.first_name.trim()
  }

  if (form.value.last_name !== props.employee.last_name) {
    updateData.last_name = form.value.last_name.trim()
  }

  if (form.value.phone !== props.employee.phone) {
    updateData.phone = form.value.phone?.trim() || ''
  }

  if (form.value.role !== props.employee.role) {
    updateData.role = form.value.role
  }

  if (form.value.active !== props.employee.active) {
    updateData.active = form.value.active
  }

  emit('save', updateData)
}

const cancel = () => {
  emit('cancel')
}

const formatDate = (dateString: string) => {
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  } catch {
    return 'Fecha inválida'
  }
}
</script>