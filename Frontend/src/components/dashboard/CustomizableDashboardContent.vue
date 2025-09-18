<template>
  <div v-if="widgets.length > 0">
    <grid-layout
      :layout="gridLayout"
      :col-num="layout.cols"
      :row-height="30"
      :is-draggable="isEditMode"
      :is-resizable="isEditMode"
      :margin="layout.margin"
      :use-css-transforms="true"
      @layout-updated="$emit('layout-updated', $event)"
    >
      <grid-item
        v-for="widget in widgets"
        :key="widget.id"
        :x="widget.position.x"
        :y="widget.position.y"
        :w="widget.position.w"
        :h="widget.position.h"
        :i="widget.id"
        :static="!isEditMode"
        class="grid-item"
        :class="{ 'selected': selectedWidget === widget.id }"
      >
        <!-- Widget Component -->
        <component
          :is="getWidgetComponent(widget.type)"
          :widget-id="widget.id"
          :title="widget.title"
          :data-source="widget.settings.data_source"
          :icon-type="widget.settings.icon"
          :color="widget.settings.color"
          v-bind="widget.settings"
          :is-edit-mode="isEditMode"
          :is-selected="selectedWidget === widget.id"
          @select="$emit('select-widget', $event)"
          @edit="$emit('edit-widget', $event)"
          @remove="$emit('remove-widget', $event)"
        />
      </grid-item>
    </grid-layout>
  </div>

  <!-- Empty State -->
  <div v-else class="text-center py-12">
    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
    </svg>
    <h3 class="mt-2 text-sm font-medium text-gray-900">No hay widgets configurados</h3>
    <p class="mt-1 text-sm text-gray-500">Comienza agregando widgets a tu dashboard.</p>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { GridLayout, GridItem } from 'vue3-grid-layout'
import { useWidgetRegistry } from '../../composables/useWidgetRegistry'
import type { Widget, DashboardLayout } from '../../services/dashboardConfig'

interface Props {
  widgets: Widget[]
  layout: DashboardLayout
  isEditMode: boolean
  selectedWidget: string | null
}

interface Emits {
  'layout-updated': [layout: any[]]
  'select-widget': [widgetId: string]
  'edit-widget': [widgetId: string]
  'remove-widget': [widgetId: string]
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const { getComponent } = useWidgetRegistry()

const gridLayout = computed(() => {
  return props.widgets.map(widget => ({
    i: widget.id,
    x: widget.position.x,
    y: widget.position.y,
    w: widget.position.w,
    h: widget.position.h
  }))
})

function getWidgetComponent(type: string) {
  return getComponent(type) || getComponent('stat_card')
}
</script>

<style scoped>
.grid-item {
  transition: all 0.2s ease;
}

.grid-item.selected {
  z-index: 10;
}

.vue-grid-layout {
  background-color: #f8fafc;
  border-radius: 8px;
  padding: 10px;
}

.vue-grid-item {
  touch-action: none;
}

.vue-grid-item.vue-grid-placeholder {
  background: #3b82f6;
  opacity: 0.2;
  transition-duration: 100ms;
  z-index: 2;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  -o-user-select: none;
  user-select: none;
}
</style>