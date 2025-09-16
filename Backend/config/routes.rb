Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount Active Storage routes
  mount ActiveStorage::Engine => "/rails/active_storage"
  
  namespace :api do
    # Authentication routes
    post '/auth/login', to: 'auth#login'
    post '/auth/logout', to: 'auth#logout'
    
    # API v1 routes
    namespace :v1 do
      resources :users
      resources :products
      resources :customers

      # Dashboard stats endpoint (must be before sales resource)
      get 'sales/stats', to: 'sales#stats'

      resources :sales do
        member do
          patch :complete
          patch :cancel
          patch :refund
        end
        resources :sale_items, except: [:index, :show]
      end
      resources :discounts
      
      # Image serving endpoint
      get 'images/:signed_id', to: 'images#show', as: :api_image
    end
  end
end
