<template>
  <div class="flex items-center">
    <div class="w-8 h-8 bg-amber-100 rounded-full flex items-center justify-center">
      <span class="text-amber-600 text-lg">🐝</span>
    </div>
    <div v-if="showText" class="ml-3">
      <div class="font-semibold text-gray-900">Little Bee's</div>
      <div class="text-xs text-gray-500">Candle Co.</div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  size?: number
  showText?: boolean
  variant?: string
  color?: string
}

withDefaults(defineProps<Props>(), {
  size: 32,
  showText: true,
  variant: "full",
  color: "amber"
})
</script>
