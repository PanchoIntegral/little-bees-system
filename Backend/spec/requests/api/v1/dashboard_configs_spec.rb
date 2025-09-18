require 'rails_helper'

RSpec.describe "Api::V1::DashboardConfigs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/dashboard_configs/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/dashboard_configs/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/dashboard_configs/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/api/v1/dashboard_configs/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/dashboard_configs/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
