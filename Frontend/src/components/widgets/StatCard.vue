<template>
  <div
    class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition-all duration-200 group"
    :class="{ 'opacity-50': loading }"
  >
    <div class="flex items-start justify-between">
      <!-- Icon with Gradient Background -->
      <div class="flex-shrink-0">
        <div
          class="w-12 h-12 rounded-xl flex items-center justify-center transition-all duration-200 group-hover:scale-110"
          :class="iconBgClass"
        >
          <component
            :is="iconComponent"
            class="w-6 h-6 text-white"
          />
        </div>
      </div>

      <!-- Trend Indicator -->
      <div v-if="trend" class="flex items-center space-x-1">
        <component
          :is="trendIcon"
          class="w-4 h-4"
          :class="trendColor"
        />
        <span class="text-sm font-medium" :class="trendColor">
          {{ trend }}
        </span>
      </div>
    </div>

    <!-- Content -->
    <div class="mt-4">
      <div class="flex items-baseline justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600 mb-1">{{ title }}</p>
          <p class="text-3xl font-bold text-gray-900 tracking-tight">
            {{ loading ? '...' : value }}
          </p>
        </div>
      </div>

      <!-- Subtitle -->
      <div v-if="subtitle" class="mt-3 pt-3 border-t border-gray-100">
        <p class="text-sm text-gray-500">{{ subtitle }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  CurrencyDollarIcon,
  ArrowTrendingUpIcon,
  ChartBarIcon,
  ExclamationTriangleIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  MinusIcon
} from '@heroicons/vue/24/outline'

interface Props {
  title: string
  value: string
  subtitle?: string
  icon: 'currency' | 'trend_up' | 'chart_bar' | 'warning'
  color: 'blue' | 'green' | 'yellow' | 'red' | 'amber'
  loading?: boolean
  trend?: string
  trendDirection?: 'up' | 'down' | 'neutral'
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  trendDirection: 'neutral'
})

const iconBgClass = computed(() => {
  const colorMap = {
    blue: 'bg-gradient-to-r from-blue-500 to-blue-600',
    green: 'bg-gradient-to-r from-emerald-500 to-emerald-600',
    yellow: 'bg-gradient-to-r from-yellow-500 to-yellow-600',
    red: 'bg-gradient-to-r from-red-500 to-red-600',
    amber: 'bg-gradient-to-r from-amber-500 to-amber-600'
  }
  return colorMap[props.color]
})

const iconComponent = computed(() => {
  const iconMap = {
    currency: CurrencyDollarIcon,
    trend_up: ArrowTrendingUpIcon,
    chart_bar: ChartBarIcon,
    warning: ExclamationTriangleIcon
  }
  return iconMap[props.icon]
})

const trendIcon = computed(() => {
  const iconMap = {
    up: ArrowUpIcon,
    down: ArrowDownIcon,
    neutral: MinusIcon
  }
  return iconMap[props.trendDirection]
})

const trendColor = computed(() => {
  const colorMap = {
    up: 'text-emerald-600',
    down: 'text-red-600',
    neutral: 'text-gray-500'
  }
  return colorMap[props.trendDirection]
})
</script>