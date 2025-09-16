require 'rails_helper'

RSpec.describe "Api::Auths", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get "/api/auth/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /logout" do
    it "returns http success" do
      get "/api/auth/logout"
      expect(response).to have_http_status(:success)
    end
  end

end
