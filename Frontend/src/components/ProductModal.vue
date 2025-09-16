<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" @click="$emit('close')">
    <div class="relative top-10 mx-auto p-5 border w-[500px] shadow-lg rounded-md bg-white" @click.stop>
      <div class="mt-3">
        <h3 class="text-lg font-medium text-gray-900 mb-4">
          {{ isEditing ? 'Edit Product' : 'Create New Product' }}
        </h3>

        <form @submit.prevent="handleSubmit">
          <div class="space-y-4">
            <!-- Name -->
            <div>
              <label for="name" class="block text-sm font-medium text-gray-700">Name</label>
              <input
                v-model="form.name"
                type="text"
                id="name"
                name="name"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>

            <!-- Description -->
            <div>
              <label for="description" class="block text-sm font-medium text-gray-700">Description</label>
              <textarea
                v-model="form.description"
                id="description"
                name="description"
                rows="3"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              ></textarea>
            </div>

            <!-- Price -->
            <div>
              <label for="price" class="block text-sm font-medium text-gray-700">Price</label>
              <input
                v-model.number="form.price"
                type="number"
                id="price"
                name="price"
                step="0.01"
                min="0"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>

            <!-- SKU -->
            <div>
              <label for="sku" class="block text-sm font-medium text-gray-700">SKU</label>
              <input
                v-model="form.sku"
                type="text"
                id="sku"
                name="sku"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>

            <!-- Category -->
            <div>
              <label for="category" class="block text-sm font-medium text-gray-700">Category</label>
              <input
                v-model="form.category"
                type="text"
                id="category"
                name="category"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>

            <!-- Stock Quantity -->
            <div>
              <label for="stock_quantity" class="block text-sm font-medium text-gray-700">Stock Quantity</label>
              <input
                v-model.number="form.stock_quantity"
                type="number"
                id="stock_quantity"
                name="stock_quantity"
                min="0"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>

            <!-- Low Stock Threshold -->
            <div>
              <label for="low_stock_threshold" class="block text-sm font-medium text-gray-700">Low Stock Threshold</label>
              <input
                v-model.number="form.low_stock_threshold"
                type="number"
                id="low_stock_threshold"
                name="low_stock_threshold"
                min="0"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>

            <!-- Image Upload -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Product Image</label>

              <!-- File Upload Area -->
              <div
                class="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md hover:border-gray-400 transition-colors"
                :class="{ 'border-indigo-400 bg-indigo-50': isDragOver }"
                @drop.prevent="handleDrop"
                @dragover.prevent="isDragOver = true"
                @dragleave.prevent="isDragOver = false"
              >
                <div class="space-y-1 text-center">
                  <!-- Preview Image -->
                  <div v-if="imagePreview" class="mb-4">
                    <img :src="imagePreview" alt="Preview" class="mx-auto h-32 w-32 object-cover rounded-lg">
                    <button
                      type="button"
                      @click="removeImage"
                      class="mt-2 text-sm text-red-600 hover:text-red-800"
                    >
                      Remove image
                    </button>
                  </div>

                  <!-- Upload Icon (when no image) -->
                  <svg v-else class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                    <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                  </svg>

                  <div class="flex text-sm text-gray-600">
                    <label for="image-upload" class="relative cursor-pointer bg-white rounded-md font-medium text-indigo-600 hover:text-indigo-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500">
                      <span>{{ imagePreview ? 'Change image' : 'Upload a file' }}</span>
                      <input
                        id="image-upload"
                        ref="fileInput"
                        type="file"
                        accept="image/*"
                        @change="handleFileSelect"
                        class="sr-only"
                      />
                    </label>
                    <p class="pl-1">or drag and drop</p>
                  </div>
                  <p class="text-xs text-gray-500">PNG, JPG, GIF up to 10MB</p>
                </div>
              </div>

            </div>

            <!-- Active -->
            <div class="flex items-center">
              <input
                v-model="form.active"
                type="checkbox"
                id="active"
                name="active"
                class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
              />
              <label for="active" class="ml-2 block text-sm text-gray-900">Active</label>
            </div>
          </div>

          <div class="flex justify-end space-x-3 mt-6">
            <button
              type="button"
              @click="$emit('close')"
              class="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="bg-indigo-600 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              {{ isEditing ? 'Update' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import type { Product } from '../services/products'

interface Props {
  product?: Product | null
  isEditing?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  product: null,
  isEditing: false
})

const emit = defineEmits<{
  close: []
  save: [data: any]
}>()

const form = ref({
  name: '',
  description: '',
  price: 0,
  sku: '',
  category: '',
  stock_quantity: 0,
  low_stock_threshold: 5,
  active: true
})

const fileInput = ref<HTMLInputElement>()
const selectedFile = ref<File | null>(null)
const imagePreview = ref<string>('')
const isDragOver = ref(false)

function handleSubmit() {
  const formData = new FormData()

  // Add form fields
  Object.keys(form.value).forEach(key => {
    const value = form.value[key as keyof typeof form.value]
    if (value !== null && value !== undefined) {
      formData.append(`product[${key}]`, String(value))
    }
  })

  // Add image file if selected
  if (selectedFile.value) {
    console.log('Submitting with image file:', {
      name: selectedFile.value.name,
      size: selectedFile.value.size,
      type: selectedFile.value.type
    })
    formData.append('product[image]', selectedFile.value)
  } else {
    console.log('No image file selected')
  }

  // Debug FormData contents
  console.log('FormData contents:')
  for (let [key, value] of formData.entries()) {
    if (value instanceof File) {
      console.log(`${key}: File(${value.name}, ${value.size} bytes, ${value.type})`)
    } else {
      console.log(`${key}: ${value}`)
    }
  }

  emit('save', formData)
}

function handleFileSelect(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

  if (file) {
    processFile(file)
  }
}

function removeImage() {
  selectedFile.value = null
  imagePreview.value = ''
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

function handleDrop(event: DragEvent) {
  isDragOver.value = false
  const files = event.dataTransfer?.files
  if (files && files.length > 0) {
    const file = files[0]
    if (file.type.startsWith('image/')) {
      processFile(file)
    }
  }
}

function processFile(file: File) {
  // Validate file type
  if (!file.type.startsWith('image/')) {
    alert('Please select an image file')
    return
  }

  // Validate file size (10MB max)
  if (file.size > 10 * 1024 * 1024) {
    alert('File size must be less than 10MB')
    return
  }

  selectedFile.value = file
  console.log('File selected:', file.name, file.size, file.type) // Debug

  // Create preview URL
  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreview.value = e.target?.result as string
  }
  reader.readAsDataURL(file)
}

function resetForm() {
  // Reset file-related state
  selectedFile.value = null
  imagePreview.value = ''
  isDragOver.value = false
  if (fileInput.value) {
    fileInput.value.value = ''
  }

  if (props.product && props.isEditing) {
    form.value = {
      name: props.product.name,
      description: props.product.description || '',
      price: props.product.price,
      sku: props.product.sku,
      category: props.product.category,
      stock_quantity: props.product.stock_quantity,
      low_stock_threshold: props.product.low_stock_threshold,
      active: props.product.active
    }

    // If editing and has image, show it as preview
    if (props.product.image_url) {
      imagePreview.value = props.product.image_url
    }
  } else {
    form.value = {
      name: '',
      description: '',
      price: 0,
      sku: '',
      category: '',
      stock_quantity: 0,
      low_stock_threshold: 5,
      active: true
    }
  }
}

// Watchers
watch(() => props.product, () => {
  resetForm()
}, { immediate: true })


onMounted(() => {
  resetForm()
})
</script>