<template>
  <Teleport to="body">
    <Transition name="toast" appear>
      <div
        v-if="show"
        class="fixed top-4 right-4 max-w-sm w-full bg-white rounded-lg shadow-lg pointer-events-auto ring-1 ring-black ring-opacity-5 overflow-hidden z-50"
      >
        <div class="p-4">
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <component
                :is="iconComponent"
                class="h-6 w-6"
                :class="iconClass"
              />
            </div>
            <div class="ml-3 w-0 flex-1 pt-0.5">
              <p class="text-sm font-medium text-gray-900">{{ title }}</p>
              <p class="mt-1 text-sm text-gray-500">{{ message }}</p>
              <div v-if="details" class="mt-2">
                <p class="text-xs text-gray-400">{{ details }}</p>
              </div>
            </div>
            <div class="ml-4 flex-shrink-0 flex">
              <button
                @click="close"
                class="bg-white rounded-md inline-flex text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                <span class="sr-only">Close</span>
                <XMarkIcon class="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>

        <!-- Progress bar for auto-dismiss -->
        <div
          v-if="autoClose"
          class="h-1 bg-gray-200"
        >
          <div
            class="h-full transition-all ease-linear"
            :class="progressBarClass"
            :style="{ width: `${progress}%` }"
          ></div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import {
  CheckCircleIcon,
  ExclamationCircleIcon,
  InformationCircleIcon,
  XCircleIcon,
  XMarkIcon,
} from '@heroicons/vue/24/outline'

interface Props {
  show: boolean
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message: string
  details?: string
  autoClose?: boolean
  duration?: number
}

const props = withDefaults(defineProps<Props>(), {
  autoClose: true,
  duration: 5000,
})

const emit = defineEmits<{
  close: []
}>()

const progress = ref(100)
let progressInterval: number | null = null
let autoCloseTimeout: number | null = null

const iconComponent = computed(() => {
  switch (props.type) {
    case 'success':
      return CheckCircleIcon
    case 'error':
      return XCircleIcon
    case 'warning':
      return ExclamationCircleIcon
    default:
      return InformationCircleIcon
  }
})

const iconClass = computed(() => {
  switch (props.type) {
    case 'success':
      return 'text-green-400'
    case 'error':
      return 'text-red-400'
    case 'warning':
      return 'text-yellow-400'
    default:
      return 'text-blue-400'
  }
})

const progressBarClass = computed(() => {
  switch (props.type) {
    case 'success':
      return 'bg-green-500'
    case 'error':
      return 'bg-red-500'
    case 'warning':
      return 'bg-yellow-500'
    default:
      return 'bg-blue-500'
  }
})

function close() {
  emit('close')
}

function startAutoClose() {
  if (!props.autoClose) return

  progress.value = 100

  const updateInterval = 50 // Update every 50ms for smooth animation
  const totalSteps = props.duration / updateInterval
  const decrement = 100 / totalSteps

  progressInterval = window.setInterval(() => {
    progress.value -= decrement
    if (progress.value <= 0) {
      progress.value = 0
      clearInterval(progressInterval!)
    }
  }, updateInterval)

  autoCloseTimeout = window.setTimeout(() => {
    close()
  }, props.duration)
}

function stopAutoClose() {
  if (progressInterval) {
    clearInterval(progressInterval)
    progressInterval = null
  }
  if (autoCloseTimeout) {
    clearTimeout(autoCloseTimeout)
    autoCloseTimeout = null
  }
}

onMounted(() => {
  if (props.show && props.autoClose) {
    startAutoClose()
  }
})

onUnmounted(() => {
  stopAutoClose()
})
</script>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease-out;
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(100%);
}
</style>