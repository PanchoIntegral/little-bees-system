<template>
  <div
    class="bg-white overflow-hidden shadow rounded-lg"
    :class="{ 'opacity-50': loading }"
  >
    <div class="p-5">
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <div
            class="w-8 h-8 rounded-md flex items-center justify-center"
            :class="iconBgClass"
          >
            <svg class="w-5 h-5" :class="iconClass" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path v-if="icon === 'currency'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
              <path v-else-if="icon === 'trend_up'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
              <path v-else-if="icon === 'chart_bar'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
              <path v-else-if="icon === 'warning'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.93-.833-2.464 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
              <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
            </svg>
          </div>
        </div>
        <div class="ml-5 w-0 flex-1">
          <dl>
            <dt class="text-sm font-medium text-gray-500 truncate">{{ title }}</dt>
            <dd class="flex items-baseline">
              <div class="text-2xl font-semibold text-gray-900">
                {{ loading ? '...' : value }}
              </div>
            </dd>
          </dl>
        </div>
      </div>
    </div>
    <div v-if="subtitle" class="bg-gray-50 px-5 py-3">
      <div class="text-sm">
        <span class="font-medium text-gray-500">{{ subtitle }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  title: string
  value: string
  subtitle?: string
  icon: 'currency' | 'trend_up' | 'chart_bar' | 'warning'
  color: 'blue' | 'green' | 'yellow' | 'red'
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false
})

const iconBgClass = computed(() => {
  const colorMap = {
    blue: 'bg-blue-500',
    green: 'bg-green-500',
    yellow: 'bg-yellow-500',
    red: 'bg-red-500'
  }
  return colorMap[props.color]
})

const iconClass = computed(() => 'text-white')
</script>