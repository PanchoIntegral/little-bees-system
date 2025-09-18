<template>
  <div class="fixed top-0 right-0 p-4 space-y-2 z-50">
    <Toast
      v-for="toast in toasts"
      :key="toast.id"
      :message="toast.message"
      :type="toast.type"
      :duration="toast.duration"
      @close="remove(toast.id)"
    />
  </div>
</template>

<script setup lang="ts">
import { useToast } from '../services/toast'
import Toast from './Toast.vue'

const { toasts, remove } = useToast()
</script>
