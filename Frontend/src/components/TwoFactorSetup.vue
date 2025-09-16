<template>
  <div class="bg-white rounded-lg shadow-lg p-6">
    <div class="mb-6">
      <h3 class="text-lg font-medium text-gray-900 mb-2">Two-Factor Authentication</h3>
      <p class="text-sm text-gray-600">
        Add an extra layer of security to your account with two-factor authentication.
      </p>
    </div>

    <!-- Current Status -->
    <div class="mb-6">
      <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
        <div class="flex items-center space-x-3">
          <div class="flex-shrink-0">
            <div :class="[
              'w-8 h-8 rounded-full flex items-center justify-center',
              status?.two_factor_enabled ? 'bg-green-100' : 'bg-gray-100'
            ]">
              <svg v-if="status?.two_factor_enabled" class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <svg v-else class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m0 0v2m0-2h2m-2 0H10m4-6V9a2 2 0 00-2-2h0a2 2 0 00-2 2v2"></path>
              </svg>
            </div>
          </div>
          <div>
            <p class="text-sm font-medium text-gray-900">
              {{ status?.two_factor_enabled ? 'Enabled' : 'Disabled' }}
            </p>
            <p class="text-sm text-gray-500">
              {{ status?.two_factor_enabled
                ? `${status.backup_codes_count} backup codes remaining`
                : 'Two-factor authentication is not enabled'
              }}
            </p>
          </div>
        </div>
        <div class="flex space-x-2">
          <button
            v-if="!status?.two_factor_enabled"
            @click="startSetup"
            :disabled="isLoading"
            class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50"
          >
            Enable 2FA
          </button>
          <template v-else>
            <button
              @click="showRegenerateCodes = true"
              :disabled="isLoading"
              class="bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 disabled:opacity-50"
            >
              Regenerate Codes
            </button>
            <button
              @click="showDisableConfirm = true"
              :disabled="isLoading"
              class="bg-red-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 disabled:opacity-50"
            >
              Disable
            </button>
          </template>
        </div>
      </div>
    </div>

    <!-- Setup Modal -->
    <div v-if="showSetup" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <div class="mb-4">
          <h4 class="text-lg font-medium text-gray-900 mb-2">Set up Two-Factor Authentication</h4>
          <p class="text-sm text-gray-600">
            Scan this QR code with your authenticator app (Google Authenticator, Authy, etc.)
          </p>
        </div>

        <!-- Step 1: Show QR Code -->
        <div v-if="setupStep === 1" class="space-y-4">
          <div v-if="qrCodeUri" class="flex justify-center p-4 bg-gray-50 rounded-lg">
            <div ref="qrCodeContainer" class="bg-white p-4 rounded"></div>
          </div>

          <div v-if="backupCodes && backupCodes.length > 0" class="space-y-2">
            <p class="text-sm font-medium text-gray-900">Backup Codes:</p>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="grid grid-cols-2 gap-2 text-sm font-mono">
                <div v-for="code in backupCodes" :key="code" class="text-gray-800">
                  {{ code }}
                </div>
              </div>
            </div>
            <p class="text-xs text-gray-500">
              Save these backup codes in a secure location. You can use them to access your account if you lose your authenticator device.
            </p>
          </div>

          <div class="flex space-x-3">
            <button
              @click="cancelSetup"
              class="flex-1 bg-gray-300 text-gray-700 py-2 px-4 rounded-md text-sm font-medium hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
            >
              Cancel
            </button>
            <button
              @click="setupStep = 2"
              class="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
            >
              Next
            </button>
          </div>
        </div>

        <!-- Step 2: Verify Code -->
        <div v-if="setupStep === 2" class="space-y-4">
          <div>
            <label for="verificationCode" class="block text-sm font-medium text-gray-700 mb-2">
              Enter verification code from your authenticator app:
            </label>
            <input
              id="verificationCode"
              v-model="verificationCode"
              type="text"
              inputmode="numeric"
              pattern="[0-9]*"
              maxlength="6"
              class="w-full px-3 py-2 border border-gray-300 rounded-md text-center text-xl tracking-widest focus:ring-blue-500 focus:border-blue-500"
              placeholder="000000"
            />
          </div>

          <div v-if="errorMessage" class="p-3 bg-red-50 border border-red-200 rounded-md">
            <p class="text-sm text-red-600">{{ errorMessage }}</p>
          </div>

          <div class="flex space-x-3">
            <button
              @click="setupStep = 1"
              class="flex-1 bg-gray-300 text-gray-700 py-2 px-4 rounded-md text-sm font-medium hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
            >
              Back
            </button>
            <button
              @click="enableTwoFactor"
              :disabled="isLoading || verificationCode.length !== 6"
              class="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="!isLoading">Enable 2FA</span>
              <span v-else class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Enabling...
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Regenerate Codes Modal -->
    <div v-if="showRegenerateCodes" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <div class="mb-4">
          <h4 class="text-lg font-medium text-gray-900 mb-2">Regenerate Backup Codes</h4>
          <p class="text-sm text-gray-600">
            Enter your authenticator code to generate new backup codes.
          </p>
        </div>

        <div class="space-y-4">
          <div>
            <input
              v-model="regenerateCode"
              type="text"
              inputmode="numeric"
              pattern="[0-9]*"
              maxlength="6"
              class="w-full px-3 py-2 border border-gray-300 rounded-md text-center text-xl tracking-widest focus:ring-blue-500 focus:border-blue-500"
              placeholder="000000"
            />
          </div>

          <div v-if="newBackupCodes && newBackupCodes.length > 0" class="space-y-2">
            <p class="text-sm font-medium text-gray-900">New Backup Codes:</p>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="grid grid-cols-2 gap-2 text-sm font-mono">
                <div v-for="code in newBackupCodes" :key="code" class="text-gray-800">
                  {{ code }}
                </div>
              </div>
            </div>
            <p class="text-xs text-gray-500">
              Your old backup codes are no longer valid. Save these new codes in a secure location.
            </p>
          </div>

          <div v-if="errorMessage" class="p-3 bg-red-50 border border-red-200 rounded-md">
            <p class="text-sm text-red-600">{{ errorMessage }}</p>
          </div>

          <div class="flex space-x-3">
            <button
              @click="cancelRegenerate"
              class="flex-1 bg-gray-300 text-gray-700 py-2 px-4 rounded-md text-sm font-medium hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
            >
              Cancel
            </button>
            <button
              @click="regenerateBackupCodes"
              :disabled="isLoading || regenerateCode.length !== 6"
              class="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="!isLoading">Generate</span>
              <span v-else>Generating...</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Disable Confirmation Modal -->
    <div v-if="showDisableConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <div class="mb-4">
          <h4 class="text-lg font-medium text-gray-900 mb-2">Disable Two-Factor Authentication</h4>
          <p class="text-sm text-gray-600">
            Enter your authenticator code to disable two-factor authentication.
          </p>
        </div>

        <div class="space-y-4">
          <div>
            <input
              v-model="disableCode"
              type="text"
              inputmode="numeric"
              pattern="[0-9]*"
              maxlength="6"
              class="w-full px-3 py-2 border border-gray-300 rounded-md text-center text-xl tracking-widest focus:ring-red-500 focus:border-red-500"
              placeholder="000000"
            />
          </div>

          <div v-if="errorMessage" class="p-3 bg-red-50 border border-red-200 rounded-md">
            <p class="text-sm text-red-600">{{ errorMessage }}</p>
          </div>

          <div class="flex space-x-3">
            <button
              @click="cancelDisable"
              class="flex-1 bg-gray-300 text-gray-700 py-2 px-4 rounded-md text-sm font-medium hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
            >
              Cancel
            </button>
            <button
              @click="disableTwoFactor"
              :disabled="isLoading || disableCode.length !== 6"
              class="flex-1 bg-red-600 text-white py-2 px-4 rounded-md text-sm font-medium hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="!isLoading">Disable 2FA</span>
              <span v-else>Disabling...</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { authService } from '../services/auth'
import QRCode from 'qrcode'

// State
const status = ref<{ two_factor_enabled: boolean; backup_codes_count: number } | null>(null)
const isLoading = ref(false)
const errorMessage = ref('')

// Setup flow
const showSetup = ref(false)
const setupStep = ref(1)
const qrCodeUri = ref('')
const backupCodes = ref<string[]>([])
const verificationCode = ref('')
const qrCodeContainer = ref<HTMLElement>()

// Regenerate codes
const showRegenerateCodes = ref(false)
const regenerateCode = ref('')
const newBackupCodes = ref<string[]>([])

// Disable 2FA
const showDisableConfirm = ref(false)
const disableCode = ref('')

const loadStatus = async () => {
  try {
    const result = await authService.getTwoFactorStatus()
    if (result) {
      status.value = result
    }
  } catch (error) {
    console.error('Failed to load 2FA status:', error)
  }
}

const startSetup = async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await authService.setupTwoFactor()

    if (result.success) {
      qrCodeUri.value = result.qr_code_uri || ''
      backupCodes.value = result.backup_codes || []
      showSetup.value = true
      setupStep.value = 1

      // Generate QR code
      nextTick(() => {
        if (qrCodeContainer.value && qrCodeUri.value) {
          QRCode.toCanvas(qrCodeContainer.value, qrCodeUri.value, { width: 200 }, (error) => {
            if (error) console.error('QR Code generation error:', error)
          })
        }
      })
    } else {
      errorMessage.value = result.message || 'Failed to setup 2FA'
    }
  } catch (error) {
    console.error('Setup 2FA error:', error)
    errorMessage.value = 'An unexpected error occurred'
  } finally {
    isLoading.value = false
  }
}

const enableTwoFactor = async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await authService.enableTwoFactor(verificationCode.value)

    if (result.success) {
      showSetup.value = false
      await loadStatus()
      resetSetupState()
    } else {
      errorMessage.value = result.message || 'Failed to enable 2FA'
    }
  } catch (error) {
    console.error('Enable 2FA error:', error)
    errorMessage.value = 'An unexpected error occurred'
  } finally {
    isLoading.value = false
  }
}

const regenerateBackupCodes = async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await authService.regenerateBackupCodes(regenerateCode.value)

    if (result.success) {
      newBackupCodes.value = result.backup_codes || []
      await loadStatus()
    } else {
      errorMessage.value = result.message || 'Failed to regenerate backup codes'
    }
  } catch (error) {
    console.error('Regenerate backup codes error:', error)
    errorMessage.value = 'An unexpected error occurred'
  } finally {
    isLoading.value = false
  }
}

const disableTwoFactor = async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await authService.disableTwoFactor(disableCode.value)

    if (result.success) {
      showDisableConfirm.value = false
      await loadStatus()
      disableCode.value = ''
    } else {
      errorMessage.value = result.message || 'Failed to disable 2FA'
    }
  } catch (error) {
    console.error('Disable 2FA error:', error)
    errorMessage.value = 'An unexpected error occurred'
  } finally {
    isLoading.value = false
  }
}

const cancelSetup = () => {
  showSetup.value = false
  resetSetupState()
}

const cancelRegenerate = () => {
  showRegenerateCodes.value = false
  regenerateCode.value = ''
  newBackupCodes.value = []
  errorMessage.value = ''
}

const cancelDisable = () => {
  showDisableConfirm.value = false
  disableCode.value = ''
  errorMessage.value = ''
}

const resetSetupState = () => {
  setupStep.value = 1
  qrCodeUri.value = ''
  backupCodes.value = []
  verificationCode.value = ''
  errorMessage.value = ''
}

onMounted(() => {
  loadStatus()
})
</script>