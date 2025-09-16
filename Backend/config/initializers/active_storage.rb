# Active Storage configuration
Rails.application.configure do
  # Set default URL options for Active Storage
  config.active_storage.variant_processor = :mini_magick if defined?(MiniMagick)

  # Configure URL options for development
  if Rails.env.development?
    config.active_storage.resolve_model_to_route = :rails_storage_redirect
    # Set CORS headers for Active Storage
    config.active_storage.draw_routes = true
  end
end

# Set default URL options after initialization
Rails.application.config.after_initialize do
  ActiveStorage::Current.url_options = {
    host: Rails.env.development? ? 'localhost:3000' : (Rails.application.config.action_mailer.default_url_options[:host] rescue 'localhost:3000'),
    protocol: Rails.env.development? ? 'http' : 'https'
  }
end