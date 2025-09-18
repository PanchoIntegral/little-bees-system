<template>
  <BaseWidget
    :widget-id="widgetId"
    :title="title"
    :icon="iconDisplay"
    :loading="loading"
    :error="error"
    :is-edit-mode="isEditMode"
    :is-selected="isSelected"
    :show-header="false"
    @select="$emit('select', $event)"
    @edit="$emit('edit', $event)"
    @remove="$emit('remove', $event)"
  >
    <div class="flex items-center h-full">
      <div class="flex-shrink-0">
        <div
          class="w-12 h-12 rounded-lg flex items-center justify-center transition-colors"
          :class="iconBgClass"
        >
          <svg class="w-6 h-6" :class="iconTextClass" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="iconType === 'currency'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
            <path v-else-if="iconType === 'trend_up'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
            <path v-else-if="iconType === 'chart_bar'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
            <path v-else-if="iconType === 'warning'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.93-.833-2.464 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
          </svg>
        </div>
      </div>
      <div class="ml-4 flex-1">
        <h3 class="text-sm font-medium text-gray-900">{{ title }}</h3>
        <p class="text-2xl font-semibold text-gray-900" :class="valueTextClass">
          <Transition name="number" mode="out-in">
            <span :key="formattedValue">{{ formattedValue }}</span>
          </Transition>
        </p>
        <p class="text-sm text-gray-500">{{ subtitle }}</p>

        <!-- Additional metadata -->
        <div v-if="showMetadata" class="mt-2 text-xs text-gray-400 space-y-1">
          <div v-if="lastRefresh" class="flex items-center space-x-1">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <span>{{ formatLastRefresh(lastRefresh) }}</span>
          </div>
          <div v-if="isEditMode" class="flex items-center space-x-1">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <span>{{ dataSource }}</span>
          </div>
        </div>
      </div>
    </div>
  </BaseWidget>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import BaseWidget from './BaseWidget.vue'
import { useWidgetData } from '../../composables/useWidgetData'

interface Props {
  widgetId: string
  title: string
  dataSource: string
  color?: 'blue' | 'green' | 'yellow' | 'red' | 'purple'
  iconType?: 'currency' | 'trend_up' | 'chart_bar' | 'warning'
  isEditMode?: boolean
  isSelected?: boolean
  showMetadata?: boolean
  autoRefresh?: boolean
  refreshInterval?: number
}

interface Emits {
  select: [widgetId: string]
  edit: [widgetId: string]
  remove: [widgetId: string]
}

const props = withDefaults(defineProps<Props>(), {
  color: 'blue',
  iconType: 'chart_bar',
  isEditMode: false,
  isSelected: false,
  showMetadata: false,
  autoRefresh: false,
  refreshInterval: 30000 // 30 seconds
})

const emit = defineEmits<Emits>()

// Use the optimized widget data composable
const {
  value: rawValue,
  formattedValue,
  subtitle,
  loading,
  error,
  lastRefresh,
  startAutoRefresh,
  stopAutoRefresh,
  fetchData
} = useWidgetData(props.widgetId, props.dataSource)

// Computed properties for styling with memoization
const iconBgClass = computed(() => {
  const colorMap = {
    blue: 'bg-blue-100 hover:bg-blue-200',
    green: 'bg-green-100 hover:bg-green-200',
    yellow: 'bg-yellow-100 hover:bg-yellow-200',
    red: 'bg-red-100 hover:bg-red-200',
    purple: 'bg-purple-100 hover:bg-purple-200'
  }
  return colorMap[props.color]
})

const iconTextClass = computed(() => {
  const colorMap = {
    blue: 'text-blue-600',
    green: 'text-green-600',
    yellow: 'text-yellow-600',
    red: 'text-red-600',
    purple: 'text-purple-600'
  }
  return colorMap[props.color]
})

const valueTextClass = computed(() => {
  if (loading.value) return 'text-gray-400'
  if (error.value) return 'text-red-600'
  return 'text-gray-900'
})

const iconDisplay = computed(() => {
  const iconMap = {
    currency: '💰',
    trend_up: '📈',
    chart_bar: '📊',
    warning: '⚠️'
  }
  return iconMap[props.iconType] || '📊'
})

// Format last refresh time
function formatLastRefresh(date: Date): string {
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)

  if (seconds < 60) {
    return `${seconds}s ago`
  } else if (minutes < 60) {
    return `${minutes}m ago`
  } else {
    return date.toLocaleTimeString()
  }
}

// Lifecycle management
onMounted(() => {
  // Initial data fetch
  fetchData()

  // Start auto-refresh if enabled
  if (props.autoRefresh) {
    startAutoRefresh(props.refreshInterval)
  }
})

onUnmounted(() => {
  // Clean up auto-refresh
  stopAutoRefresh()
})
</script>

<style scoped>
/* Number transition animation */
.number-enter-active,
.number-leave-active {
  transition: all 0.3s ease;
}

.number-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.number-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

/* Hover effects */
.widget-container:hover .transition-colors {
  transition-duration: 200ms;
}

/* Loading state shimmer effect */
@keyframes shimmer {
  0% {
    background-position: -200px 0;
  }
  100% {
    background-position: calc(200px + 100%) 0;
  }
}

.loading-shimmer {
  background: linear-gradient(90deg, #f3f4f6 25%, #e5e7eb 50%, #f3f4f6 75%);
  background-size: 200px 100%;
  animation: shimmer 1.5s infinite;
}
</style>