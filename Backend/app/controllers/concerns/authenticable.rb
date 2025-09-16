module Authenticable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  def authorize_admin
    render json: { error: 'Admin access required' }, status: 403 unless current_user&.admin?
  end

  def authorize_manager_or_admin
    render json: { error: 'Manager or Admin access required' }, status: 403 unless current_user&.can_manage_users?
  end

  def current_user_json
    {
      id: current_user.id,
      email: current_user.email,
      first_name: current_user.first_name,
      last_name: current_user.last_name,
      full_name: current_user.full_name,
      role: current_user.role,
      two_factor_enabled: current_user.two_factor_enabled?
    }
  end
end