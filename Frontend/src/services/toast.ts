import { ref, readonly } from 'vue'

interface Toast {
  id: number
  message: string
  type: 'success' | 'error'
  duration: number
}

const toasts = ref<Toast[]>([])

let toastId = 0

function show(message: string, type: 'success' | 'error' = 'success', duration = 3000) {
  const id = toastId++
  toasts.value.push({ id, message, type, duration })
}

function remove(id: number) {
  const index = toasts.value.findIndex(toast => toast.id === id)
  if (index !== -1) {
    toasts.value.splice(index, 1)
  }
}

export const useToast = () => {
  return {
    toasts: readonly(toasts),
    show,
    remove
  }
}
