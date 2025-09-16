<template>
  <Teleport to="body">
    <Transition name="modal" appear>
      <div
        v-if="show"
        class="fixed inset-0 bg-black bg-opacity-50 modal-backdrop flex items-center justify-center p-4 z-50"
        @click="handleBackdropClick"
      >
        <div
          class="bg-white rounded-lg shadow-xl max-w-md w-full mx-auto transform transition-all"
          @click.stop
        >
          <!-- Header -->
          <div class="flex items-center p-6 pb-4">
            <div
              class="flex-shrink-0 w-12 h-12 mx-auto flex items-center justify-center rounded-full"
              :class="iconBackgroundClass"
            >
              <component :is="iconComponent" class="w-6 h-6" :class="iconClass" />
            </div>
          </div>

          <!-- Content -->
          <div class="px-6 pb-4">
            <h3 class="text-lg font-medium text-gray-900 text-center mb-2">
              {{ title }}
            </h3>
            <p class="text-sm text-gray-500 text-center">
              {{ message }}
            </p>

            <!-- Additional details if provided -->
            <div v-if="details" class="mt-3 p-3 bg-gray-50 rounded-md">
              <p class="text-xs text-gray-600">{{ details }}</p>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-3 p-6 pt-4">
            <button
              @click="handleCancel"
              class="flex-1 bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors btn-hover-lift"
            >
              {{ cancelText }}
            </button>
            <button
              @click="handleConfirm"
              class="flex-1 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors btn-hover-lift"
              :class="[confirmButtonClass, { 'pulse-danger': type === 'danger' }]"
            >
              {{ confirmText }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  ExclamationTriangleIcon,
  TrashIcon,
  QuestionMarkCircleIcon,
  InformationCircleIcon,
} from '@heroicons/vue/24/outline'

interface Props {
  show: boolean
  title: string
  message: string
  details?: string
  type?: 'danger' | 'warning' | 'info' | 'question'
  confirmText?: string
  cancelText?: string
  allowBackdropClose?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  type: 'question',
  confirmText: 'Confirm',
  cancelText: 'Cancel',
  allowBackdropClose: true,
})

const emit = defineEmits<{
  confirm: []
  cancel: []
  close: []
}>()

const iconComponent = computed(() => {
  switch (props.type) {
    case 'danger':
      return TrashIcon
    case 'warning':
      return ExclamationTriangleIcon
    case 'info':
      return InformationCircleIcon
    default:
      return QuestionMarkCircleIcon
  }
})

const iconClass = computed(() => {
  switch (props.type) {
    case 'danger':
      return 'text-red-600'
    case 'warning':
      return 'text-yellow-600'
    case 'info':
      return 'text-blue-600'
    default:
      return 'text-gray-600'
  }
})

const iconBackgroundClass = computed(() => {
  switch (props.type) {
    case 'danger':
      return 'bg-red-100'
    case 'warning':
      return 'bg-yellow-100'
    case 'info':
      return 'bg-blue-100'
    default:
      return 'bg-gray-100'
  }
})

const confirmButtonClass = computed(() => {
  switch (props.type) {
    case 'danger':
      return 'bg-red-600 hover:bg-red-700 focus:ring-red-500'
    case 'warning':
      return 'bg-yellow-600 hover:bg-yellow-700 focus:ring-yellow-500'
    case 'info':
      return 'bg-blue-600 hover:bg-blue-700 focus:ring-blue-500'
    default:
      return 'bg-indigo-600 hover:bg-indigo-700 focus:ring-indigo-500'
  }
})

function handleConfirm() {
  emit('confirm')
  emit('close')
}

function handleCancel() {
  emit('cancel')
  emit('close')
}

function handleBackdropClick() {
  if (props.allowBackdropClose) {
    handleCancel()
  }
}
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .bg-white,
.modal-leave-active .bg-white {
  transition: all 0.3s ease;
}

.modal-enter-from .bg-white,
.modal-leave-to .bg-white {
  transform: scale(0.9);
  opacity: 0;
}
</style>