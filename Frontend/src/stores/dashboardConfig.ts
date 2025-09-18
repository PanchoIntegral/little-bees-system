import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import {
  dashboardConfigService,
  type DashboardConfig,
  type Widget,
  type DashboardConfigFull,
  type DashboardConfigResponse
} from '../services/dashboardConfig'
import { useWidgetRegistry } from '../composables/useWidgetRegistry'

export const useDashboardConfigStore = defineStore('dashboardConfig', () => {
  // State
  const currentConfig = ref<DashboardConfig | null>(null)
  const currentConfigMeta = ref<DashboardConfigResponse | null>(null)
  const availableConfigs = ref<DashboardConfigResponse[]>([])
  const isEditMode = ref(false)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const hasConfig = computed(() => currentConfig.value !== null)
  const widgets = computed(() => currentConfig.value?.widgets || [])
  const layout = computed(() => currentConfig.value?.layout || {
    cols: 12,
    margin: [10, 10],
    container_padding: [15, 15]
  })

  const { getAllWidgets } = useWidgetRegistry()

  const availableWidgetTypes = computed(() =>
    getAllWidgets().map(widget => ({
      type: widget.type,
      name: widget.name,
      description: widget.description,
      icon: widget.icon,
      defaultSize: widget.defaultSize
    }))
  )

  // Actions
  async function fetchCurrentConfig(layoutName = 'default') {
    loading.value = true
    error.value = null

    console.log('Fetching dashboard config for layout:', layoutName)

    try {
      const response = await dashboardConfigService.getCurrentConfig(layoutName)
      console.log('Dashboard config response:', response)
      currentConfig.value = response.parsed_config
      currentConfigMeta.value = response.config
      console.log('Config set successfully:', currentConfig.value)
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch dashboard configuration'
      console.error('Error fetching dashboard config:', err)
      console.error('Error details:', err.response)
    } finally {
      loading.value = false
    }
  }

  async function fetchAvailableConfigs() {
    loading.value = true
    error.value = null

    try {
      const response = await dashboardConfigService.getConfigs()
      availableConfigs.value = response.configs
      if (!currentConfig.value) {
        currentConfig.value = response.current_config
      }
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to fetch available configurations'
      console.error('Error fetching available configs:', err)
    } finally {
      loading.value = false
    }
  }

  async function updateWidget(widgetId: string, updates: Partial<Widget>) {
    if (!currentConfig.value) return

    try {
      const response = await dashboardConfigService.updateWidget(
        widgetId,
        updates,
        currentConfigMeta.value?.layout_name
      )
      currentConfig.value = response.parsed_config
      currentConfigMeta.value = response.config
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to update widget'
      console.error('Error updating widget:', err)
      throw err
    }
  }

  async function addWidget(widget: Widget) {
    try {
      const response = await dashboardConfigService.addWidget(
        widget,
        currentConfigMeta.value?.layout_name
      )
      currentConfig.value = response.parsed_config
      currentConfigMeta.value = response.config
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to add widget'
      console.error('Error adding widget:', err)
      throw err
    }
  }

  async function removeWidget(widgetId: string) {
    try {
      const response = await dashboardConfigService.removeWidget(
        widgetId,
        currentConfigMeta.value?.layout_name
      )
      currentConfig.value = response.parsed_config
      currentConfigMeta.value = response.config
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to remove widget'
      console.error('Error removing widget:', err)
      throw err
    }
  }

  async function resetToDefault() {
    try {
      const response = await dashboardConfigService.resetToDefault(
        currentConfigMeta.value?.layout_name
      )
      currentConfig.value = response.parsed_config
      currentConfigMeta.value = response.config
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to reset configuration'
      console.error('Error resetting config:', err)
      throw err
    }
  }

  function enableEditMode() {
    isEditMode.value = true
  }

  function disableEditMode() {
    isEditMode.value = false
  }

  function toggleEditMode() {
    isEditMode.value = !isEditMode.value
  }

  // Local widget manipulation (for preview before saving)
  function updateWidgetLocal(widgetId: string, updates: Partial<Widget>) {
    if (!currentConfig.value) return

    const widgetIndex = currentConfig.value.widgets.findIndex(w => w.id === widgetId)
    if (widgetIndex !== -1) {
      currentConfig.value.widgets[widgetIndex] = {
        ...currentConfig.value.widgets[widgetIndex],
        ...updates
      }
    }
  }

  function addWidgetLocal(widget: Widget) {
    if (!currentConfig.value) return
    currentConfig.value.widgets.push(widget)
  }

  function removeWidgetLocal(widgetId: string) {
    if (!currentConfig.value) return
    currentConfig.value.widgets = currentConfig.value.widgets.filter(w => w.id !== widgetId)
  }

  async function saveCurrentConfig() {
    if (!currentConfig.value || !currentConfigMeta.value) return

    try {
      const response = await dashboardConfigService.updateConfig(
        currentConfigMeta.value.id,
        { config: currentConfig.value }
      )
      currentConfig.value = response.parsed_config
      currentConfigMeta.value = response.config
    } catch (err: any) {
      error.value = err.response?.data?.error || 'Failed to save configuration'
      console.error('Error saving config:', err)
      throw err
    }
  }

  function clearError() {
    error.value = null
  }

  return {
    // State
    currentConfig,
    currentConfigMeta,
    availableConfigs,
    isEditMode,
    loading,
    error,

    // Getters
    hasConfig,
    widgets,
    layout,
    availableWidgetTypes,

    // Actions
    fetchCurrentConfig,
    fetchAvailableConfigs,
    updateWidget,
    addWidget,
    removeWidget,
    resetToDefault,
    enableEditMode,
    disableEditMode,
    toggleEditMode,
    updateWidgetLocal,
    addWidgetLocal,
    removeWidgetLocal,
    saveCurrentConfig,
    clearError
  }
})