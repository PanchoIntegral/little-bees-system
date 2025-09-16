class Api::BaseController < ActionController::API
  include Response

  # Set JSON as default response format
  before_action :set_default_response_format

  # Optional authentication - will set current_user if token is present
  before_action :authenticate_request_optional

  protected

  def authenticate_request_optional
    token = extract_token_from_header

    if token
      begin
        decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })[0]
        @current_user = User.find(decoded_token['user_id'])
      rescue JWT::ExpiredSignature
        render json: { error: 'Token has expired' }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :unauthorized
      end
    else
      # No token provided - continue without authentication
      # This allows the API to work without login for now
      @current_user = nil
    end
  end

  def authenticate_request!
    authenticate_request_optional
    unless current_user
      render json: { error: 'Authentication required' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def require_admin!
    unless current_user&.admin?
      render json: { error: 'Admin access required' }, status: :forbidden
    end
  end

  def require_manager_or_admin!
    unless current_user&.can_manage_users?
      render json: { error: 'Manager or Admin access required' }, status: :forbidden
    end
  end

  private

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    # Extract token from "Bearer TOKEN" format
    auth_header.split(' ').last if auth_header.start_with?('Bearer ')
  end

  def set_default_response_format
    request.format = :json
  end
end