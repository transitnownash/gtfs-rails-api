# frozen_string_literal: true

##
# Default Controller
class DefaultController < ApplicationController
  before_action :set_endpoints, only: [:index]

  def index
    render json: @endpoints
  end

  private

  def set_endpoints
    @endpoints = []
    Rails.application.routes.routes.map do |route|
      path = route.path.spec.to_s
      next if path =~ %r{^/(rails|cable)}

      @endpoints << path.gsub('(.:format)', '.json')
    end
    @endpoints = @endpoints.uniq
  end
end
