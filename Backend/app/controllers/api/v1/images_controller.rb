class Api::V1::ImagesController < ApplicationController
  # Skip authentication for image serving
  skip_before_action :authenticate_request
  
  def show
    Rails.logger.info "Serving image with signed_id: #{params[:signed_id]}"
    
    begin
      blob = ActiveStorage::Blob.find_signed(params[:signed_id])
      
      if blob.nil?
        Rails.logger.error "Blob not found for signed_id: #{params[:signed_id]}"
        head :not_found
        return
      end
      
      Rails.logger.info "Found blob: #{blob.filename}, content_type: #{blob.content_type}"
      
      # Set proper headers for image serving
      response.headers['Cache-Control'] = 'public, max-age=3600'
      response.headers['Content-Type'] = blob.content_type
      response.headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
      
      # Stream the file data
      send_data blob.download,
                type: blob.content_type,
                disposition: 'inline',
                filename: blob.filename.to_s
                
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error "File not found: #{e.message}"
      head :not_found
    rescue => e
      Rails.logger.error "Error serving image: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      head :internal_server_error
    end
  end
end
