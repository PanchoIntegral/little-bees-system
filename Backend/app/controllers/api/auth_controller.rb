class Api::AuthController < Api::BaseController
  # Skip authentication for login endpoint
  
  def login
    user = User.find_by(email: params[:email]&.downcase&.strip)
    
    if user && user.authenticate(params[:password])
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
          role: user.role
        }
      }
    else
      render json: {
        success: false,
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def logout
    # In a stateless JWT system, logout is handled client-side
    # But we can add token blacklisting here if needed
    render json: {
      success: true,
      message: 'Logged out successfully'
    }
  end

  private

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      role: user.role,
      exp: 24.hours.from_now.to_i # Token expires in 24 hours
    }
    
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
