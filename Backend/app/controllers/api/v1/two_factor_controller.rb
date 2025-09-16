class Api::V1::TwoFactorController < Api::BaseController
  before_action :authenticate_request

  def show
    render json: {
      two_factor_enabled: current_user.two_factor_enabled?,
      backup_codes_count: current_user.backup_codes_count
    }
  end

  def setup
    if current_user.two_factor_enabled?
      render json: {
        success: false,
        message: 'Two-factor authentication is already enabled'
      }, status: :unprocessable_entity
      return
    end

    current_user.setup_two_factor!

    render json: {
      success: true,
      qr_code_uri: current_user.generate_qr_code,
      backup_codes: current_user.backup_codes,
      message: 'Two-factor authentication has been set up. Please save your backup codes in a secure location.'
    }
  end

  def enable
    unless params[:code].present?
      render json: {
        success: false,
        message: 'Verification code is required'
      }, status: :unprocessable_entity
      return
    end

    if current_user.verify_two_factor(params[:code])
      current_user.update!(two_factor_enabled: true)

      render json: {
        success: true,
        message: 'Two-factor authentication has been enabled successfully'
      }
    else
      render json: {
        success: false,
        message: 'Invalid verification code'
      }, status: :unprocessable_entity
    end
  end

  def disable
    unless params[:code].present?
      render json: {
        success: false,
        message: 'Verification code is required to disable two-factor authentication'
      }, status: :unprocessable_entity
      return
    end

    if current_user.verify_two_factor(params[:code])
      current_user.disable_two_factor!

      render json: {
        success: true,
        message: 'Two-factor authentication has been disabled'
      }
    else
      render json: {
        success: false,
        message: 'Invalid verification code'
      }, status: :unprocessable_entity
    end
  end

  def regenerate_backup_codes
    unless params[:code].present?
      render json: {
        success: false,
        message: 'Verification code is required'
      }, status: :unprocessable_entity
      return
    end

    if current_user.verify_two_factor(params[:code])
      current_user.regenerate_backup_codes!

      render json: {
        success: true,
        backup_codes: current_user.backup_codes,
        message: 'New backup codes have been generated. Please save them in a secure location.'
      }
    else
      render json: {
        success: false,
        message: 'Invalid verification code'
      }, status: :unprocessable_entity
    end
  end

  def verify
    unless params[:code].present?
      render json: {
        success: false,
        message: 'Verification code is required'
      }, status: :unprocessable_entity
      return
    end

    if current_user.verify_two_factor(params[:code])
      render json: {
        success: true,
        message: 'Code verified successfully'
      }
    else
      render json: {
        success: false,
        message: 'Invalid verification code'
      }, status: :unprocessable_entity
    end
  end

  def qr_code
    unless current_user.two_factor_secret.present?
      render json: {
        success: false,
        message: 'Two-factor authentication is not set up'
      }, status: :unprocessable_entity
      return
    end

    render json: {
      qr_code_uri: current_user.generate_qr_code
    }
  end
end