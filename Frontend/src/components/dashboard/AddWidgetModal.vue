<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" @click="$emit('close')">
    <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white" @click.stop>
      <h3 class="text-lg font-medium text-gray-900 mb-4">Agregar Widget</h3>

      <div class="space-y-3">
        <div
          v-for="widgetType in availableWidgetTypes"
          :key="widgetType.type"
          @click="$emit('add-widget', widgetType)"
          class="p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
        >
          <div class="flex items-center">
            <span class="text-2xl mr-3">{{ widgetType.icon }}</span>
            <div>
              <h4 class="font-medium text-gray-900">{{ widgetType.name }}</h4>
              <p class="text-sm text-gray-500">{{ widgetType.description }}</p>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-6 flex justify-end space-x-3">
        <button @click="$emit('close')" class="btn btn-outline">
          Cancelar
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  availableWidgetTypes: any[]
}

interface Emits {
  'add-widget': [widgetType: any]
  'close': []
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()
</script>

<style scoped>
.btn {
  @apply inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2;
}

.btn-outline {
  @apply text-gray-700 bg-white border-gray-300 hover:bg-gray-50 focus:ring-blue-500;
}
</style>