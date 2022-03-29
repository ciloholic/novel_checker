# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def render404
    @error = { status: 404, message: t('server_errors.defaults.status404') }
    render status: :not_found, template: 'errors/error'
  end

  def render500
    @error = { status: 500, message: t('server_errors.defaults.status500') }
    render status: :internal_server_error, template: 'errors/error'
  end
end
