<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <!-- Minimal Navigation -->
    <nav v-if="currentUser" class="bg-white/80 backdrop-blur-md border-b border-gray-100">
      <div class="max-w-6xl mx-auto px-6">
        <div class="flex justify-between items-center h-20">
          <!-- Logo -->
          <RouterLink to="/" class="flex items-center group">
            <Logo :size="28" :show-text="true" variant="full" />
          </RouterLink>
          
          <!-- Navigation Links -->
          <div class="hidden md:flex items-center space-x-8">
            <RouterLink 
              to="/" 
              class="relative px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 transition-all duration-200 group"
              :class="{ 'text-amber-600': $route.name === 'dashboard' }"
            >
              Dashboard
              <div class="absolute bottom-0 left-0 w-full h-0.5 bg-amber-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-200" :class="{ 'scale-x-100': $route.name === 'dashboard' }"></div>
            </RouterLink>
            
            <RouterLink 
              to="/products" 
              class="relative px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 transition-all duration-200 group"
              :class="{ 'text-amber-600': $route.name === 'products' }"
            >
              Products
              <div class="absolute bottom-0 left-0 w-full h-0.5 bg-amber-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-200" :class="{ 'scale-x-100': $route.name === 'products' }"></div>
            </RouterLink>
            
            <RouterLink 
              to="/sales" 
              class="relative px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 transition-all duration-200 group"
              :class="{ 'text-amber-600': $route.name === 'sales' }"
            >
              Sales
              <div class="absolute bottom-0 left-0 w-full h-0.5 bg-amber-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-200" :class="{ 'scale-x-100': $route.name === 'sales' }"></div>
            </RouterLink>
            
            <RouterLink 
              to="/customers" 
              class="relative px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 transition-all duration-200 group"
              :class="{ 'text-amber-600': $route.name === 'customers' }"
            >
              Customers
              <div class="absolute bottom-0 left-0 w-full h-0.5 bg-amber-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-200" :class="{ 'scale-x-100': $route.name === 'customers' }"></div>
            </RouterLink>

            <!-- User Menu -->
            <div class="flex items-center space-x-4 ml-8 pl-8 border-l border-gray-200">
              <!-- User Info with Dropdown -->
              <div ref="userMenuRef" class="relative">
                <button
                  @click.stop="showUserMenu = !showUserMenu"
                  class="flex items-center space-x-2 px-3 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 rounded-lg hover:bg-gray-50 transition-all duration-200"
                >
                  <div class="w-8 h-8 bg-amber-100 rounded-full flex items-center justify-center">
                    <svg class="w-4 h-4 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                  </div>
                  <span>{{ currentUser?.full_name || 'User' }}</span>
                  <svg class="w-4 h-4 text-gray-400" :class="{ 'rotate-180': showUserMenu }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                  </svg>
                </button>

                <!-- Dropdown Menu -->
                <transition
                  enter-active-class="transition ease-out duration-100"
                  enter-from-class="transform opacity-0 scale-95"
                  enter-to-class="transform opacity-100 scale-100"
                  leave-active-class="transition ease-in duration-75"
                  leave-from-class="transform opacity-100 scale-100"
                  leave-to-class="transform opacity-0 scale-95"
                >
                  <div v-if="showUserMenu" @click.stop class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-100 py-1 z-50 origin-top-right">
                  <RouterLink
                    to="/settings"
                    @click="showUserMenu = false"
                    class="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    <svg class="w-4 h-4 mr-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                    </svg>
                    Configuración
                  </RouterLink>

                  <div v-if="currentUser?.two_factor_enabled" class="px-4 py-2">
                    <div class="flex items-center">
                      <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                        <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                        </svg>
                        2FA Activo
                      </span>
                    </div>
                  </div>

                  <hr class="my-1 border-gray-100">

                  <button
                    @click.stop="handleLogoutClick"
                    class="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors"
                  >
                    <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                    </svg>
                    Cerrar Sesión
                  </button>
                  </div>
                </transition>
              </div>
            </div>
          </div>

          <!-- Mobile menu button -->
          <button class="md:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors">
            <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
          </button>
        </div>
      </div>
    </nav>
    
    <!-- Main Content -->
    <main :class="currentUser ? 'max-w-6xl mx-auto px-6 py-8' : ''">
      <RouterView />
    </main>

    <!-- Global Notification Container -->
    <NotificationContainer />

    <!-- Logout Modal -->
    <LogoutModal
      :show="showLogoutModal"
      :user="currentUser"
      :is-loading="isLoggingOut"
      @cancel="cancelLogout"
      @confirm="confirmLogout"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import Logo from './components/Logo.vue'
import NotificationContainer from './components/NotificationContainer.vue'
import LogoutModal from './components/LogoutModal.vue'
import { useLogout } from './composables/useLogout'
import { authService } from './services/auth'

const currentUser = computed(() => authService.currentUser.value)
const showUserMenu = ref(false)
const userMenuRef = ref<HTMLElement | null>(null)

// Logout functionality
const {
  showLogoutModal,
  isLoggingOut,
  showLogoutDialog,
  cancelLogout,
  confirmLogout
} = useLogout()

const handleLogoutClick = () => {
  showUserMenu.value = false
  showLogoutDialog()
}

// Close user menu when clicking outside
const closeUserMenu = (event: Event) => {
  const target = event.target as HTMLElement

  // Only close if clicked outside the user menu container
  if (userMenuRef.value && !userMenuRef.value.contains(target) && showUserMenu.value) {
    showUserMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', closeUserMenu)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', closeUserMenu)
})
</script>