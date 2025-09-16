class Api::V1::Auth::SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  # POST /api/v1/auth/login
  def create
    auth_response = Auth::AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    
    if auth_response
      user = auth_response[:user]
      
      # Update sign in tracking
      user.update!(
        current_sign_in_at: Time.current,
        last_sign_in_at: user.current_sign_in_at || Time.current,
        sign_in_count: user.sign_in_count + 1
      )

      json_response({
        message: 'Login successful',
        token: auth_response[:token],
        user: user_json(user),
        expires_at: 24.hours.from_now
      })
    end
  rescue ExceptionHandler::AuthenticationError => e
    json_response({ message: e.message }, :unauthorized)
  end

  # DELETE /api/v1/auth/logout
  def destroy
    # JWT tokens are stateless, so we just return success
    # In a production app, you might want to blacklist the token
    json_response({ message: 'Logged out successfully' })
  end

  # POST /api/v1/auth/refresh
  def refresh
    # Generate new token for current user
    token = JsonWebToken.encode(user_id: current_user.id)
    
    json_response({
      message: 'Token refreshed',
      token: token,
      user: current_user_json,
      expires_at: 24.hours.from_now
    })
  end

  # GET /api/v1/auth/me
  def me
    json_response({
      user: current_user_json
    })
  end

  private

  def auth_params
    params.require(:auth).permit(:email, :password)
  rescue ActionController::ParameterMissing
    params.permit(:email, :password)
  end

  def user_json(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.role,
      two_factor_enabled: user.two_factor_enabled?,
      last_sign_in_at: user.last_sign_in_at,
      permissions: {
        can_manage_users: user.can_manage_users?,
        can_access_reports: user.can_access_reports?
      }
    }
  end
end