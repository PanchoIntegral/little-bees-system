class Api::DebugController < ApplicationController
  # Only available in development
  before_action :check_development_mode

  def sms_code
    user = User.find(params[:user_id])

    render json: {
      code: user.sms_verification_code,
      expires_at: user.sms_code_expires_at,
      expired: user.sms_code_expired?
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  private

  def check_development_mode
    unless Rails.env.development?
      render json: { error: 'Debug endpoint only available in development' }, status: :forbidden
    end
  end
end