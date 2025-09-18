class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_request
  before_action :ensure_admin_or_manager, only: [:index, :show, :update, :destroy]
  before_action :ensure_admin, only: [:destroy]
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = User.all.order(:first_name, :last_name)

    # Apply filters if provided
    @users = @users.where(role: params[:role]) if params[:role].present?
    @users = @users.where(active: params[:active]) if params[:active].present?

    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
        search_term, search_term, search_term
      )
    end

    users_data = @users.map do |user|
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        full_name: user.full_name,
        role: user.role,
        active: user.active,
        two_factor_enabled: user.two_factor_enabled?,
        phone_verified: user.phone_verified?,
        last_sign_in_at: user.last_sign_in_at,
        sign_in_count: user.sign_in_count,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    end

    render json: {
      success: true,
      users: users_data,
      total: @users.count
    }
  end

  def show
    render json: {
      success: true,
      user: user_data(@user)
    }
  end

  def update
    # Only admins can change roles and activate/deactivate users
    if params[:role].present? && !current_user.admin?
      render json: {
        success: false,
        message: 'Only administrators can change user roles'
      }, status: :forbidden
      return
    end

    # Users can't deactivate themselves
    if params[:active] == false && @user.id == current_user.id
      render json: {
        success: false,
        message: 'You cannot deactivate your own account'
      }, status: :forbidden
      return
    end

    if @user.update(user_update_params)
      render json: {
        success: true,
        message: 'User updated successfully',
        user: user_data(@user)
      }
    else
      render json: {
        success: false,
        message: 'Failed to update user',
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    # Prevent deletion of the last admin
    if @user.admin? && User.admins.count == 1
      render json: {
        success: false,
        message: 'Cannot delete the last administrator account'
      }, status: :forbidden
      return
    end

    # Prevent users from deleting themselves
    if @user.id == current_user.id
      render json: {
        success: false,
        message: 'You cannot delete your own account'
      }, status: :forbidden
      return
    end

    if @user.destroy
      render json: {
        success: true,
        message: 'User deleted successfully'
      }
    else
      render json: {
        success: false,
        message: 'Failed to delete user'
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      message: 'User not found'
    }, status: :not_found
  end

  def ensure_admin_or_manager
    unless current_user&.can_manage_users?
      render json: {
        success: false,
        message: 'Access denied. Administrators and managers only.'
      }, status: :forbidden
    end
  end

  def ensure_admin
    unless current_user&.admin?
      render json: {
        success: false,
        message: 'Access denied. Administrators only.'
      }, status: :forbidden
    end
  end

  def user_update_params
    allowed_params = [:first_name, :last_name, :phone, :active]
    allowed_params << :role if current_user.admin?
    params.permit(allowed_params)
  end

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.role,
      active: user.active,
      two_factor_enabled: user.two_factor_enabled?,
      phone_verified: user.phone_verified?,
      last_sign_in_at: user.last_sign_in_at,
      sign_in_count: user.sign_in_count,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end