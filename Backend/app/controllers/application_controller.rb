class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include Authenticable

  # Skip authentication for health check
  before_action :authenticate_request, except: [:index]

  private

  def authenticate_request
    @current_user = Auth::AuthorizeApiRequest.new(request).call[:result]
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
