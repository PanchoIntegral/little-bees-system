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
              <span class="text-sm text-gray-600">{{ currentUser?.full_name || 'User' }}</span>
              <button 
                @click="handleLogout"
                class="px-3 py-1.5 text-sm font-medium text-gray-600 hover:text-red-600 transition-colors"
              >
                Logout
              </button>
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
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import Logo from './components/Logo.vue'
import NotificationContainer from './components/NotificationContainer.vue'
import { authService } from './services/auth'

const router = useRouter()

const currentUser = computed(() => authService.currentUser.value)

const handleLogout = () => {
  authService.logout()
  router.push('/login')
}
</script>