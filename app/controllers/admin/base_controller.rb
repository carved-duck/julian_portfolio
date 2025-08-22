module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin

    private

    def authenticate_admin
      authenticate_or_request_with_http_basic("Admin Area") do |username, password|
        username == ENV['ADMIN_USERNAME'] && password == ENV['ADMIN_PASSWORD']
      end
    end
  end
end
