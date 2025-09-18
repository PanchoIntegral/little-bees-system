import { Component, defineAsyncComponent } from 'vue'

export interface WidgetDefinition {
  type: string
  name: string
  description: string
  icon: string
  component: Component
  defaultSize: {
    w: number
    h: number
  }
  defaultSettings: Record<string, any>
  category: 'analytics' | 'sales' | 'inventory' | 'finance'
  dependencies?: string[]
  permissions?: string[]
}

class WidgetRegistry {
  private widgets = new Map<string, WidgetDefinition>()

  register(definition: WidgetDefinition) {
    this.widgets.set(definition.type, definition)
  }

  get(type: string): WidgetDefinition | undefined {
    return this.widgets.get(type)
  }

  getAll(): WidgetDefinition[] {
    return Array.from(this.widgets.values())
  }

  getByCategory(category: string): WidgetDefinition[] {
    return Array.from(this.widgets.values()).filter(w => w.category === category)
  }

  getComponent(type: string): Component | undefined {
    return this.widgets.get(type)?.component
  }

  getDefaultSettings(type: string): Record<string, any> {
    return this.widgets.get(type)?.defaultSettings || {}
  }

  unregister(type: string): boolean {
    return this.widgets.delete(type)
  }

  exists(type: string): boolean {
    return this.widgets.has(type)
  }
}

// Global widget registry instance
const widgetRegistry = new WidgetRegistry()

// Lazy load widget components for better performance
const LazyStatCardWidget = defineAsyncComponent(() =>
  import('../components/widgets/StatCardWidget.vue')
)

const LazyDailyBreakdownWidget = defineAsyncComponent(() =>
  import('../components/widgets/DailyBreakdownWidget.vue')
)

const LazyPaymentStatsWidget = defineAsyncComponent(() =>
  import('../components/widgets/PaymentStatsWidget.vue')
)

const LazyInventoryAlertsWidget = defineAsyncComponent(() =>
  import('../components/widgets/InventoryAlertsWidget.vue')
)

// Register default widgets
widgetRegistry.register({
  type: 'stat_card',
  name: 'Tarjeta de Estadística',
  description: 'Muestra métricas numéricas con iconos',
  icon: '📊',
  component: LazyStatCardWidget,
  defaultSize: { w: 3, h: 2 },
  defaultSettings: {
    icon: 'chart_bar',
    color: 'blue',
    data_source: 'today_revenue'
  },
  category: 'analytics'
})

widgetRegistry.register({
  type: 'daily_breakdown',
  name: 'Ventas Diarias',
  description: 'Desglose de ventas por día',
  icon: '📅',
  component: LazyDailyBreakdownWidget,
  defaultSize: { w: 6, h: 6 },
  defaultSettings: {
    days: 7,
    show_details: true
  },
  category: 'sales'
})

widgetRegistry.register({
  type: 'payment_stats',
  name: 'Estadísticas de Pago',
  description: 'Análisis de métodos de pago',
  icon: '💳',
  component: LazyPaymentStatsWidget,
  defaultSize: { w: 12, h: 4 },
  defaultSettings: {
    show_chart: true,
    period: 'month'
  },
  category: 'finance'
})

widgetRegistry.register({
  type: 'inventory_alerts',
  name: 'Alertas de Inventario',
  description: 'Productos con stock bajo',
  icon: '⚠️',
  component: LazyInventoryAlertsWidget,
  defaultSize: { w: 6, h: 6 },
  defaultSettings: {
    limit: 5,
    show_out_of_stock: true,
    show_low_stock: true
  },
  category: 'inventory'
})

export function useWidgetRegistry() {
  return {
    registry: widgetRegistry,

    // Helper functions
    getWidget: (type: string) => widgetRegistry.get(type),
    getAllWidgets: () => widgetRegistry.getAll(),
    getWidgetsByCategory: (category: string) => widgetRegistry.getByCategory(category),
    getComponent: (type: string) => widgetRegistry.getComponent(type),
    getDefaultSettings: (type: string) => widgetRegistry.getDefaultSettings(type),
    registerWidget: (definition: WidgetDefinition) => widgetRegistry.register(definition),

    // Widget categories
    getCategories: () => ['analytics', 'sales', 'inventory', 'finance'] as const,

    // Validation
    isValidWidget: (type: string) => widgetRegistry.exists(type)
  }
}

export default widgetRegistry