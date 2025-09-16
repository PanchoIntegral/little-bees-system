import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../views/Dashboard.vue'
import { authService } from '../services/auth'

const router = createRouter({
  history: createWebHistory('/'),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard,
      meta: { requiresAuth: true }
    },
    {
      path: '/products',
      name: 'products',
      component: () => import('../views/Products.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/sales',
      name: 'sales',
      component: () => import('../views/Sales.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/customers',
      name: 'customers',
      component: () => import('../views/Customers.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import('../views/Profile.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/settings',
      name: 'settings',
      component: () => import('../views/Settings.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/Login.vue'),
      meta: { requiresAuth: false }
    }
  ]
})

// Navigation guard for authentication
router.beforeEach((to, _from, next) => {
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const isAuthenticated = authService.isAuthenticated()

  if (requiresAuth && !isAuthenticated) {
    // Redirect to login if not authenticated
    next('/login')
  } else if (to.path === '/login' && isAuthenticated) {
    // Redirect to dashboard if already authenticated and trying to access login
    next('/')
  } else {
    next()
  }
})

export default router