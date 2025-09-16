import { ref, reactive } from 'vue'

export interface Notification {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message: string
  details?: string
  autoClose?: boolean
  duration?: number
}

const notifications = ref<Notification[]>([])

let notificationId = 0

export function useNotifications() {
  function addNotification(notification: Omit<Notification, 'id'>) {
    const id = `notification-${++notificationId}`
    const newNotification = {
      id,
      autoClose: true,
      duration: 5000,
      ...notification,
    }

    notifications.value.push(newNotification)

    // Auto-remove after duration if autoClose is enabled
    if (newNotification.autoClose) {
      setTimeout(() => {
        removeNotification(id)
      }, newNotification.duration + 500) // Add extra time for animation
    }

    return id
  }

  function removeNotification(id: string) {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index > -1) {
      notifications.value.splice(index, 1)
    }
  }

  function clearAll() {
    notifications.value = []
  }

  // Convenience methods
  function success(title: string, message: string, details?: string) {
    return addNotification({
      type: 'success',
      title,
      message,
      details,
    })
  }

  function error(title: string, message: string, details?: string) {
    return addNotification({
      type: 'error',
      title,
      message,
      details,
      autoClose: false, // Errors should stay visible
    })
  }

  function warning(title: string, message: string, details?: string) {
    return addNotification({
      type: 'warning',
      title,
      message,
      details,
      duration: 7000, // Warnings stay a bit longer
    })
  }

  function info(title: string, message: string, details?: string) {
    return addNotification({
      type: 'info',
      title,
      message,
      details,
    })
  }

  return {
    notifications,
    addNotification,
    removeNotification,
    clearAll,
    success,
    error,
    warning,
    info,
  }
}