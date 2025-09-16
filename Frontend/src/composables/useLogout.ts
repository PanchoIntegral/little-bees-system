import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { authService } from '../services/auth'

export function useLogout() {
  const router = useRouter()
  const showLogoutModal = ref(false)
  const isLoggingOut = ref(false)

  const showLogoutDialog = () => {
    showLogoutModal.value = true
  }

  const cancelLogout = () => {
    showLogoutModal.value = false
  }

  const confirmLogout = async () => {
    isLoggingOut.value = true

    try {
      await authService.logout()
      showLogoutModal.value = false

      // Pequeña pausa para mostrar feedback visual
      setTimeout(() => {
        router.push('/login')
      }, 500)
    } catch (error) {
      console.error('Logout failed:', error)
      // Force logout even if API call fails
      showLogoutModal.value = false
      setTimeout(() => {
        router.push('/login')
      }, 500)
    } finally {
      isLoggingOut.value = false
    }
  }

  return {
    showLogoutModal,
    isLoggingOut,
    showLogoutDialog,
    cancelLogout,
    confirmLogout
  }
}