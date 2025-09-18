import { apiService } from './api'

export interface WidgetPosition {
  x: number
  y: number
  w: number
  h: number
}

export interface WidgetSettings {
  [key: string]: any
}

export interface Widget {
  id: string
  type: string
  title: string
  position: WidgetPosition
  settings: WidgetSettings
}

export interface DashboardLayout {
  cols: number
  margin: [number, number]
  container_padding: [number, number]
}

export interface DashboardConfig {
  widgets: Widget[]
  layout: DashboardLayout
}

export interface DashboardConfigResponse {
  id: number
  layout_name: string
  active: boolean
  created_at: string
  updated_at: string
}

export interface DashboardConfigFull {
  config: DashboardConfigResponse
  parsed_config: DashboardConfig
}

export interface DashboardConfigsListResponse {
  configs: DashboardConfigResponse[]
  current_config: DashboardConfig
}

class DashboardConfigService {
  async getConfigs(): Promise<DashboardConfigsListResponse> {
    return apiService.get<DashboardConfigsListResponse>('/v1/dashboard_configs')
  }

  async getCurrentConfig(layoutName = 'default'): Promise<DashboardConfigFull> {
    return apiService.get<DashboardConfigFull>(`/v1/dashboard_configs/current?layout_name=${layoutName}`)
  }

  async getConfig(id: number): Promise<DashboardConfigFull> {
    return apiService.get<DashboardConfigFull>(`/v1/dashboard_configs/${id}`)
  }

  async createConfig(data: {
    layout_name: string
    config: DashboardConfig
    active?: boolean
  }): Promise<DashboardConfigFull> {
    return apiService.post<DashboardConfigFull>('/v1/dashboard_configs', {
      dashboard_config: data
    })
  }

  async updateConfig(id: number, data: {
    layout_name?: string
    config?: DashboardConfig
    active?: boolean
  }): Promise<DashboardConfigFull> {
    return apiService.put<DashboardConfigFull>(`/v1/dashboard_configs/${id}`, {
      dashboard_config: data
    })
  }

  async deleteConfig(id: number): Promise<{ message: string }> {
    return apiService.delete<{ message: string }>(`/v1/dashboard_configs/${id}`)
  }

  async updateWidget(
    widgetId: string,
    widgetData: Partial<Widget>,
    layoutName = 'default'
  ): Promise<DashboardConfigFull> {
    return apiService.patch<DashboardConfigFull>(`/v1/dashboard_configs/update_widget`, {
      widget_id: widgetId,
      widget_data: widgetData,
      layout_name: layoutName
    })
  }

  async addWidget(
    widgetData: Widget,
    layoutName = 'default'
  ): Promise<DashboardConfigFull> {
    return apiService.post<DashboardConfigFull>(`/v1/dashboard_configs/add_widget`, {
      widget_data: widgetData,
      layout_name: layoutName
    })
  }

  async removeWidget(
    widgetId: string,
    layoutName = 'default'
  ): Promise<DashboardConfigFull> {
    // For DELETE requests, send data in the request body
    return apiService.request<DashboardConfigFull>({
      method: 'DELETE',
      url: `/v1/dashboard_configs/remove_widget`,
      data: {
        widget_id: widgetId,
        layout_name: layoutName
      }
    })
  }

  async resetToDefault(layoutName = 'default'): Promise<DashboardConfigFull> {
    return apiService.post<DashboardConfigFull>(`/v1/dashboard_configs/reset_default`, {
      layout_name: layoutName
    })
  }
}

export const dashboardConfigService = new DashboardConfigService()