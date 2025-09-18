<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
      <div class="mt-3">
        <h3 class="text-lg font-medium text-gray-900 text-center mb-4">
          Crear Nueva Oferta
        </h3>

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <!-- Nombre -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nombre de la Oferta *</label>
            <input
              v-model="form.name"
              type="text"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
              placeholder="Ej: Descuento de Verano"
            />
          </div>

          <!-- Descripción -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
            <textarea
              v-model="form.description"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
              rows="2"
              placeholder="Descripción opcional"
            ></textarea>
          </div>

          <!-- Tipo de Descuento -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Tipo de Descuento *</label>
            <select
              v-model="form.discount_type"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              <option value="">Selecciona un tipo</option>
              <option value="percentage">Porcentaje (%)</option>
              <option value="fixed_amount">Monto Fijo ($)</option>
            </select>
          </div>

          <!-- Valor del Descuento -->
          <div v-if="form.discount_type">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              {{ form.discount_type === 'percentage' ? 'Porcentaje (1-100%)' : 'Monto ($)' }} *
            </label>
            <div class="relative">
              <input
                v-model.number="form.discount_value"
                type="number"
                :min="form.discount_type === 'percentage' ? 1 : 0.01"
                :max="form.discount_type === 'percentage' ? 100 : undefined"
                step="0.01"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
                :placeholder="form.discount_type === 'percentage' ? '10' : '20.00'"
              />
              <span class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-500">
                {{ form.discount_type === 'percentage' ? '%' : '$' }}
              </span>
            </div>
          </div>

          <!-- Compra Mínima -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Compra Mínima (Opcional)</label>
            <div class="relative">
              <input
                v-model.number="form.minimum_amount"
                type="number"
                min="0"
                step="0.01"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
                placeholder="0.00"
              />
              <span class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-500">$</span>
            </div>
            <p class="text-xs text-gray-500 mt-1">Deja en 0 para aplicar a cualquier compra</p>
          </div>

          <!-- Vista Previa -->
          <div v-if="form.discount_type && form.discount_value > 0" class="bg-green-50 p-3 rounded">
            <h4 class="text-sm font-medium text-green-800 mb-1">Vista Previa:</h4>
            <p class="text-sm text-green-700">
              {{ getPreviewText() }}
            </p>
          </div>

          <!-- Botones -->
          <div class="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              @click="$emit('close')"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
            >
              Cancelar
            </button>
            <button
              type="submit"
              :disabled="!isFormValid || processing"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
            >
              {{ processing ? 'Creando...' : 'Crear Oferta' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { offersService } from '../services/offers'

interface Emits {
  close: []
  success: [offer: any]
}

const emit = defineEmits<Emits>()

// Form data que coincide exactamente con el backend
const form = ref({
  name: '',
  description: '',
  discount_type: '',
  discount_value: 0,
  minimum_amount: 0,
  active: true
})

const processing = ref(false)

// Validación simple
const isFormValid = computed(() => {
  return form.value.name.trim() &&
         form.value.discount_type &&
         form.value.discount_value > 0 &&
         (form.value.discount_type !== 'percentage' || form.value.discount_value <= 100)
})

// Funciones
function getPreviewText() {
  const { discount_type, discount_value, minimum_amount } = form.value

  let text = ''
  if (discount_type === 'percentage') {
    text = `${discount_value}% de descuento`
  } else {
    text = `$${discount_value} de descuento`
  }

  if (minimum_amount > 0) {
    text += ` en compras de $${minimum_amount} o más`
  } else {
    text += ` en cualquier compra`
  }

  return text
}

async function handleSubmit() {
  if (!isFormValid.value) return

  processing.value = true

  try {
    console.log('💾 Enviando datos al backend:', form.value)

    const newOffer = await offersService.createOffer(form.value)

    console.log('✅ Oferta creada exitosamente:', newOffer)
    emit('success', newOffer)
  } catch (error) {
    console.error('❌ Error creando oferta:', error)
    alert('Error al crear la oferta. Verifica los datos e intenta de nuevo.')
  } finally {
    processing.value = false
  }
}
</script>