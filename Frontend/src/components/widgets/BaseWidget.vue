<template>
  <div
    class="widget-container bg-white rounded-lg shadow-md border border-gray-200 overflow-hidden"
    :class="{
      'border-blue-300 shadow-lg': isEditMode && isSelected,
      'hover:shadow-lg transition-shadow': !isEditMode,
      'cursor-move': isEditMode
    }"
    @click="selectWidget"
  >
    <!-- Widget Header -->
    <div
      v-if="showHeader"
      class="widget-header flex items-center justify-between px-4 py-3 border-b border-gray-100"
      :class="{
        'bg-gray-50': isEditMode,
        'bg-white': !isEditMode
      }"
    >
      <div class="flex items-center space-x-2">
        <span v-if="icon" class="text-lg">{{ icon }}</span>
        <h3 class="text-sm font-medium text-gray-900">{{ title }}</h3>
      </div>

      <!-- Edit Controls -->
      <div v-if="isEditMode" class="flex items-center space-x-1">
        <button
          @click.stop="editWidget"
          class="p-1 text-gray-400 hover:text-gray-600 transition-colors"
          title="Edit Widget"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
          </svg>
        </button>
        <button
          @click.stop="removeWidget"
          class="p-1 text-red-400 hover:text-red-600 transition-colors"
          title="Remove Widget"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
          </svg>
        </button>
      </div>
    </div>

    <!-- Widget Content -->
    <div class="widget-content p-4">
      <slot />
    </div>

    <!-- Loading Overlay -->
    <div
      v-if="loading"
      class="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center"
    >
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>

    <!-- Error Overlay -->
    <div
      v-if="error"
      class="absolute inset-0 bg-red-50 border border-red-200 flex items-center justify-center p-4"
    >
      <div class="text-center">
        <svg class="mx-auto h-8 w-8 text-red-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.93-.833-2.464 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z" />
        </svg>
        <p class="text-sm text-red-600">{{ error }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  widgetId: string
  title: string
  icon?: string
  showHeader?: boolean
  loading?: boolean
  error?: string | null
  isEditMode?: boolean
  isSelected?: boolean
}

interface Emits {
  select: [widgetId: string]
  edit: [widgetId: string]
  remove: [widgetId: string]
}

const props = withDefaults(defineProps<Props>(), {
  showHeader: true,
  loading: false,
  error: null,
  isEditMode: false,
  isSelected: false
})

const emit = defineEmits<Emits>()

function selectWidget() {
  if (props.isEditMode) {
    emit('select', props.widgetId)
  }
}

function editWidget() {
  emit('edit', props.widgetId)
}

function removeWidget() {
  emit('remove', props.widgetId)
}
</script>

<style scoped>
.widget-container {
  position: relative;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.widget-content {
  flex: 1;
  overflow: auto;
}
</style>