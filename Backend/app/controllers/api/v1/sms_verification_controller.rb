class Api::V1::SmsVerificationController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, only: [:send_code, :verify_code, :enable, :disable]
  before_action :rate_limit_sms, only: [:send_code]

  # POST /api/v1/sms_verification/send_code
  def send_code
    if @user.phone_number.blank?
      return render json: {
        success: false,
        message: 'Phone number is required'
      }, status: :unprocessable_entity
    end

    result = @user.send_sms_verification_code

    if result[:success]
      render json: {
        success: true,
        message: 'Verification code sent successfully',
        expires_in_minutes: 10
      }
    else
      render json: {
        success: false,
        message: result[:message]
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/sms_verification/verify_code
  def verify_code
    code = params[:code]

    if code.blank?
      return render json: {
        success: false,
        message: 'Verification code is required'
      }, status: :unprocessable_entity
    end

    if @user.verify_sms_code(code)
      render json: {
        success: true,
        message: 'Phone number verified successfully',
        phone_verified: true
      }
    else
      render json: {
        success: false,
        message: 'Invalid or expired verification code'
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/sms_verification/enable
  def enable
    unless @user.phone_verified?
      return render json: {
        success: false,
        message: 'Phone number must be verified first'
      }, status: :unprocessable_entity
    end

    @user.enable_sms_verification!

    render json: {
      success: true,
      message: 'SMS verification enabled successfully',
      sms_verification_enabled: true
    }
  end

  # POST /api/v1/sms_verification/disable
  def disable
    @user.disable_sms_verification!

    render json: {
      success: true,
      message: 'SMS verification disabled successfully',
      sms_verification_enabled: false
    }
  end

  # POST /api/v1/sms_verification/setup
  def setup
    phone_number = params[:phone_number]

    if phone_number.blank?
      return render json: {
        success: false,
        message: 'Phone number is required'
      }, status: :unprocessable_entity
    end

    # Validate phone number format
    unless phone_number.match?(/\A\+?[1-9]\d{1,14}\z/)
      return render json: {
        success: false,
        message: 'Invalid phone number format'
      }, status: :unprocessable_entity
    end

    # Check if phone number is already taken
    if User.where(phone_number: phone_number).where.not(id: @user.id).exists?
      return render json: {
        success: false,
        message: 'Phone number is already registered'
      }, status: :unprocessable_entity
    end

    @user.phone_number = phone_number
    @user.phone_verified_at = nil # Reset verification status

    if @user.save
      result = @user.send_sms_verification_code

      if result[:success]
        render json: {
          success: true,
          message: 'Phone number updated and verification code sent',
          phone_number: @user.phone_number,
          expires_in_minutes: 10
        }
      else
        render json: {
          success: false,
          message: result[:message]
        }, status: :unprocessable_entity
      end
    else
      render json: {
        success: false,
        message: @user.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/sms_verification/status
  def status
    render json: {
      phone_number: @user.phone_number,
      phone_verified: @user.phone_verified?,
      sms_verification_enabled: @user.sms_verification_enabled?,
      has_pending_code: @user.sms_verification_code.present? && !@user.sms_code_expired?
    }
  end

  private

  def find_user
    @user = current_user
  end

  def rate_limit_sms
    cache_key = "sms_attempts:#{@user.id}"
    attempts = Rails.cache.read(cache_key) || 0

    if attempts >= 3
      return render json: {
        success: false,
        message: 'Too many SMS requests. Please wait 5 minutes before requesting another code.'
      }, status: :too_many_requests
    end

    Rails.cache.write(cache_key, attempts + 1, expires_in: 5.minutes)
  end
end