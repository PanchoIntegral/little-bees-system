<template>
  <div class="flex items-center">
    <!-- Professional Hexagonal Logo -->
    <div
      class="relative flex items-center justify-center transition-all duration-200"
      :class="logoSizeClass"
    >
      <!-- Hexagonal Background -->
      <svg
        :width="size"
        :height="size"
        viewBox="0 0 48 48"
        class="absolute inset-0"
        :class="hexagonColorClass"
      >
        <path d="M24 2l11.196 6.464v12.928L24 27.856l-11.196-6.464V8.464L24 2z"
              fill="currentColor"
              opacity="0.1"/>
        <path d="M24 4.5l9.526 5.5v11L24 26.5l-9.526-5.5v-11L24 4.5z"
              fill="currentColor"
              opacity="0.2"/>
        <path d="M24 7l7.794 4.5v9L24 25l-7.794-4.5v-9L24 7z"
              fill="currentColor"/>
      </svg>

      <!-- Bee Icon -->
      <svg
        :width="iconSize"
        :height="iconSize"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.5"
        class="relative z-10 text-white"
      >
        <!-- Stylized Bee Body -->
        <ellipse cx="12" cy="12" rx="3" ry="6" transform="rotate(25 12 12)"/>
        <!-- Bee Stripes -->
        <path d="M10.5 9.5h3M10 12h4M10.5 14.5h3" stroke-linecap="round"/>
        <!-- Bee Wings -->
        <path d="M8 8c-1.5-1.5-3-1-3 0s1.5 1.5 3 0zM16 8c1.5-1.5 3-1 3 0s-1.5 1.5-3 0z"
              fill="currentColor" opacity="0.7"/>
        <path d="M8.5 10c-1-1-2.5-0.5-2.5 0.5s1.5 1.5 2.5 0.5zM15.5 10c1-1 2.5-0.5 2.5 0.5s-1.5 1.5-2.5 0.5z"
              fill="currentColor" opacity="0.5"/>
      </svg>
    </div>

    <!-- Text Content -->
    <div v-if="showText" class="ml-4">
      <div class="font-bold text-gray-900 tracking-tight leading-none" :class="titleSizeClass">
        Little Bee's
      </div>
      <div class="text-gray-500 font-medium tracking-wide" :class="subtitleSizeClass">
        {{ variant === 'full' ? 'Candle Co.' : 'POS System' }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  size?: number
  showText?: boolean
  variant?: 'full' | 'icon' | 'compact'
  color?: 'amber' | 'primary' | 'dark'
}

const props = withDefaults(defineProps<Props>(), {
  size: 32,
  showText: true,
  variant: 'full',
  color: 'amber'
})

const iconSize = computed(() => Math.round(props.size * 0.5))

const logoSizeClass = computed(() => {
  const sizeMap = {
    24: 'w-6 h-6',
    28: 'w-7 h-7',
    32: 'w-8 h-8',
    40: 'w-10 h-10',
    48: 'w-12 h-12',
    56: 'w-14 h-14',
    64: 'w-16 h-16'
  }
  return sizeMap[props.size as keyof typeof sizeMap] || 'w-8 h-8'
})

const hexagonColorClass = computed(() => {
  const colorMap = {
    amber: 'text-amber-500 hover:text-amber-600',
    primary: 'text-primary-500 hover:text-primary-600',
    dark: 'text-gray-700 hover:text-gray-800'
  }
  return colorMap[props.color]
})

const titleSizeClass = computed(() => {
  if (props.size >= 48) return 'text-xl'
  if (props.size >= 32) return 'text-base'
  return 'text-sm'
})

const subtitleSizeClass = computed(() => {
  if (props.size >= 48) return 'text-sm'
  if (props.size >= 32) return 'text-xs'
  return 'text-xs'
})
</script>
