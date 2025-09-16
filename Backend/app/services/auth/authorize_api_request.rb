class Auth::AuthorizeApiRequest
  def initialize(request = nil)
    @request = request
  end

  def call
    { result: user }
  end

  private

  attr_reader :request

  def user
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
  rescue ActiveRecord::RecordNotFound => e
    raise(ExceptionHandler::InvalidToken, ("Invalid token"))
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def http_auth_header
    if request.headers['Authorization'].present?
      return request.headers['Authorization'].split(' ').last
    end
    raise(ExceptionHandler::MissingToken, 'Missing token')
  end
end