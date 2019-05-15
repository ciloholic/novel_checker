# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CommonActions
  before_action :authenticate_admin_user!, :set_sites
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, ActionView::MissingTemplate, with: :render_404
  rescue_from Exception, with: :render_500

  def render_404
    @error = { status: 404, message: t('server_errors.defaults.status404') }
    render status: :not_found, template: 'errors/error'
  end

  def render_500
    @error = { status: 500, message: t('server_errors.defaults.status500') }
    render status: :internal_server_error, template: 'errors/error'
  end
end
