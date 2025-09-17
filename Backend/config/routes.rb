Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount Active Storage routes
  mount ActiveStorage::Engine => "/rails/active_storage"
  
  namespace :api do
    # Authentication routes
    post '/auth/login', to: 'auth#login'
    post '/auth/logout', to: 'auth#logout'
    post '/auth/verify_two_factor', to: 'auth#verify_two_factor'
    post '/auth/request_sms_code', to: 'auth#request_sms_code'
    post '/auth/change_password', to: 'auth#change_password'
    post '/auth/refresh_token', to: 'auth#refresh_token'

    # Debug routes (development only)
    if Rails.env.development?
      post '/debug/sms_code', to: 'debug#sms_code'
    end

    # API v1 routes
    namespace :v1 do
      resources :users
      resources :products
      resources :customers

      # Dashboard stats endpoint (must be before sales resource)
      get 'sales/stats', to: 'sales#stats'

      resources :sales do
        collection do
          delete :destroy_all
        end
        member do
          patch :complete
          patch :cancel
          patch :refund
        end
        resources :sale_items, except: [:index, :show]
      end
      resources :discounts

      # Two-Factor Authentication routes
      resource :two_factor, only: [:show], controller: 'two_factor' do
        post :setup
        post :enable
        post :disable
        post :regenerate_backup_codes
        post :verify
        get :qr_code
      end

      # SMS Verification routes
      resource :sms_verification, only: [], controller: 'sms_verification' do
        post :setup
        post :send_code
        post :verify_code
        post :enable
        post :disable
        get :status
      end

      # Image serving endpoint
      get 'images/:signed_id', to: 'images#show', as: :api_image
    end
  end
end
