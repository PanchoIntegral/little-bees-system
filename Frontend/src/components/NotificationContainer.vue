<template>
  <div class="fixed top-4 right-4 space-y-4 z-50 pointer-events-none">
    <NotificationToast
      v-for="notification in notifications"
      :key="notification.id"
      :show="true"
      :type="notification.type"
      :title="notification.title"
      :message="notification.message"
      :details="notification.details"
      :auto-close="notification.autoClose"
      :duration="notification.duration"
      @close="removeNotification(notification.id)"
      class="pointer-events-auto"
    />
  </div>
</template>

<script setup lang="ts">
import { useNotifications } from '../composables/useNotifications'
import NotificationToast from './NotificationToast.vue'

const { notifications, removeNotification } = useNotifications()
</script>