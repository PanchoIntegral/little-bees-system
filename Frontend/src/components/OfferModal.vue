<template>
  <div v-if="show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
      <div class="p-6">
        <!-- Header -->
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold text-gray-900">
            {{ isEditing ? 'Editar Oferta' : 'Nueva Oferta' }}
          </h2>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Basic Information -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Nombre de la Oferta *</label>
              <input v-model="form.name" type="text" required class="form-input w-full" placeholder="Ej: Descuento de Temporada" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de Oferta *</label>
              <select v-model="form.discount_type" required class="form-input w-full">
                <option value="">Selecciona un tipo</option>
                <option value="percentage">Descuento Porcentual</option>
                <option value="fixed_amount">Descuento Fijo</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Descripción</label>
            <textarea v-model="form.description" class="form-input w-full h-20 resize-none" placeholder="Describe los detalles de la oferta..."></textarea>
          </div>

          <!-- Offer Configuration -->
          <div v-if="form.discount_type" class="bg-gray-50 p-6 rounded-lg">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Configuración de la Oferta</h3>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                {{ form.discount_type === 'percentage' ? 'Porcentaje de Descuento *' : 'Monto de Descuento *' }}
              </label>
              <div class="relative">
                <input v-model.number="form.discount_value" type="number" :min="form.discount_type === 'percentage' ? 1 : 0.01" :max="form.discount_type === 'percentage' ? 100 : undefined" step="0.01" required class="form-input w-full" :placeholder="form.discount_type === 'percentage' ? '20' : '10.00'" />
                <span class="absolute right-3 top-3 text-gray-500">{{ form.discount_type === 'percentage' ? '%' : '$' }}</span>
              </div>
            </div>
          </div>

          <!-- Conditions -->
          <div class="bg-yellow-50 p-6 rounded-lg">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Condiciones</h3>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Compra Mínima *</label>
              <div class="relative">
                <input v-model.number="form.minimum_amount" type="number" min="0" step="0.01" required class="form-input w-full pl-8" placeholder="0.00" />
                <span class="absolute left-3 top-3 text-gray-500">$</span>
              </div>
              <p class="text-xs text-gray-500 mt-1">Monto mínimo de compra para aplicar el descuento. 0 para aplicar a todas las compras.</p>
            </div>
          </div>
          
          <!-- Status -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Estado</label>
            <select v-model="form.active" class="form-input w-full">
              <option :value="true">Activo</option>
              <option :value="false">Inactivo</option>
            </select>
          </div>

          <!-- Actions -->
          <div class="flex justify-end space-x-4 pt-6 border-t">
            <button type="button" @click="$emit('close')" class="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50">
              Cancelar
            </button>
            <button type="submit" :disabled="!isFormValid || processing" class="bg-amber-600 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white hover:bg-amber-700 disabled:opacity-50">
              <span v-if="processing">Procesando...</span>
              <span v-else>{{ isEditing ? 'Actualizar Oferta' : 'Crear Oferta' }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';

interface Props {
  show: boolean;
  offer?: any;
}

const props = defineProps<Props>();
const emit = defineEmits<{
  close: [];
  success: [offer: any];
}>();

const processing = ref(false);

const getInitialFormState = () => ({
  name: '',
  description: '',
  discount_type: '',
  discount_value: 0,
  minimum_amount: 0,
  active: true,
});

const form = ref(getInitialFormState());

const isEditing = computed(() => !!props.offer);

const isFormValid = computed(() => {
  return form.value.name.trim() &&
         form.value.discount_type &&
         form.value.discount_value > 0 &&
         (form.value.discount_type !== 'percentage' || form.value.discount_value <= 100);
});

async function handleSubmit() {
  if (!isFormValid.value) return;

  processing.value = true;
  try {
    // The form object now directly matches the backend structure
    emit('success', { ...form.value });
  } catch (error) {
    console.error('Error submitting offer:', error);
    // You might want to show a toast notification here
  } finally {
    processing.value = false;
  }
}

watch(() => props.show, (newVal) => {
  if (newVal) {
    if (isEditing.value && props.offer) {
      // Editing: Populate form with offer data
      form.value = {
        name: props.offer.name || '',
        description: props.offer.description || '',
        discount_type: props.offer.discount_type || '',
        discount_value: props.offer.discount_value || 0,
        minimum_amount: props.offer.minimum_amount || 0,
        active: props.offer.active === undefined ? true : props.offer.active,
      };
    } else {
      // Creating: Reset to initial state
      form.value = getInitialFormState();
    }
  }
});
</script>

<style scoped>
.form-input {
  @apply block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-amber-500 focus:border-amber-500 sm:text-sm;
}
</style>
