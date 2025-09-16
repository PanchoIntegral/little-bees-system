class Api::AuthController < Api::BaseController
  # Skip authentication for login endpoint
  before_action :rate_limit_login, only: [:login, :verify_two_factor]

  def login
    user = User.find_by(email: params[:email]&.downcase&.strip)

    unless user
      render json: {
        success: false,
        message: 'Invalid email or password'
      }, status: :unauthorized
      return
    end

    # Check if account is locked
    if user.access_locked?
      render json: {
        success: false,
        message: 'Account is temporarily locked due to too many failed attempts'
      }, status: :locked
      return
    end

    # Check if account is active and confirmed
    unless user.active_for_authentication?
      render json: {
        success: false,
        message: 'Account is not active or confirmed'
      }, status: :forbidden
      return
    end

    if user.authenticate(params[:password])
      # Reset failed attempts on successful authentication
      user.reset_failed_attempts!

      # Check if 2FA is enabled
      if user.two_factor_enabled?
        verification_methods = ['totp']

        # Check if SMS verification is also available
        if user.sms_verification_enabled? && user.phone_verified?
          verification_methods << 'sms'
        end

        render json: {
          success: true,
          requires_two_factor: true,
          user_id: user.id,
          verification_methods: verification_methods,
          message: 'Please provide your two-factor authentication code'
        }
      else
        # Check if password has expired
        if user.password_expired?
          render json: {
            success: true,
            requires_password_change: true,
            user_id: user.id,
            message: 'Your password has expired. Please change it.'
          }
        else
          complete_login(user)
        end
      end
    else
      # Increment failed attempts
      user.increment_failed_attempts!

      render json: {
        success: false,
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def verify_two_factor
    user = User.find(params[:user_id])
    code = params[:code]
    method = params[:method] || 'totp' # Default to TOTP

    verified = case method
               when 'totp'
                 user.verify_two_factor(code)
               when 'sms'
                 user.verify_sms_code(code)
               else
                 false
               end

    if verified
      complete_login(user)
    else
      user.increment_failed_attempts!

      render json: {
        success: false,
        message: 'Invalid verification code'
      }, status: :unauthorized
    end
  end

  # New endpoint to request SMS code during login
  def request_sms_code
    user = User.find(params[:user_id])

    unless user.sms_verification_enabled? && user.phone_verified?
      render json: {
        success: false,
        message: 'SMS verification not available for this user'
      }, status: :unprocessable_entity
      return
    end

    result = user.send_sms_verification_code

    if result[:success]
      render json: {
        success: true,
        message: 'SMS code sent successfully'
      }
    else
      render json: {
        success: false,
        message: result[:message]
      }, status: :unprocessable_entity
    end
  end

  def logout
    # Invalidate session token
    if current_user
      current_user.invalidate_session!
    end

    render json: {
      success: true,
      message: 'Logged out successfully'
    }
  end

  def change_password
    user = User.find(params[:user_id])

    unless user.authenticate(params[:current_password])
      render json: {
        success: false,
        message: 'Current password is incorrect'
      }, status: :unauthorized
      return
    end

    if user.update(password: params[:new_password], must_change_password: false)
      # Invalidate all sessions
      user.regenerate_session_token!

      render json: {
        success: true,
        message: 'Password changed successfully'
      }
    else
      render json: {
        success: false,
        message: 'Password change failed',
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def refresh_token
    if current_user&.active_for_authentication?
      token = generate_jwt_token(current_user)
      render json: {
        success: true,
        token: token
      }
    else
      render json: {
        success: false,
        message: 'Invalid session'
      }, status: :unauthorized
    end
  end

  private

  def complete_login(user)
    # Update login tracking
    user.update!(
      current_sign_in_at: Time.current,
      last_sign_in_at: user.current_sign_in_at,
      sign_in_count: user.sign_in_count + 1
    )

    # Generate new session token
    user.regenerate_session_token!

    # Generate JWT token
    token = generate_jwt_token(user)

    render json: {
      success: true,
      token: token,
      user: {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        full_name: user.full_name,
        role: user.role,
        two_factor_enabled: user.two_factor_enabled?,
        must_change_password: user.must_change_password?
      }
    }
  end

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      role: user.role,
      session_token: user.session_token,
      exp: 24.hours.from_now.to_i # Token expires in 24 hours
    }

    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def rate_limit_login
    # Simple rate limiting based on IP
    key = "login_attempts:#{request.remote_ip}"
    attempts = Rails.cache.read(key) || 0

    if attempts >= 10
      render json: {
        success: false,
        message: 'Too many login attempts. Please try again later.'
      }, status: :too_many_requests
      return
    end

    Rails.cache.write(key, attempts + 1, expires_in: 15.minutes)
  end
end
