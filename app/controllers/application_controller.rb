# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_admin_user!
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, ActionView::MissingTemplate, with: :render_404
  rescue_from Exception, with: :render_500

  def render_404
    # @asides = Site.includes(:novels).where.not(novels: { title: nil }).reorder('novels.restrict asc, novels.code asc')
    @error = { status: 404, message: t('server_errors.defaults.status404') }
    render status: :not_found, template: 'errors/error'
  end

  def render_500
    # @asides = Site.includes(:novels).where.not(novels: { title: nil }).reorder('novels.restrict asc, novels.code asc')
    @error = { status: 500, message: t('server_errors.defaults.status500') }
    render status: :internal_server_error, template: 'errors/error'
  end
end
