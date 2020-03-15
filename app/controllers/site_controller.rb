# frozen_string_literal: true

class SiteController < ApplicationController
  include CommonActions
  before_action :set_sites
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, ActionView::MissingTemplate, with: :render_404
  rescue_from Exception, with: :render_500

  def top
    @notifications = Novel.published.includes(:site).limit(100).reorder('novels.updated_at desc')
  end

  def index
    @params = permit_params
    render_404 unless code?
    @novel = Novel.includes(:site, :chapters).where(id: @params[:novel_id], sites: { code: @params[:code] }).reorder('chapters.chapter').first
    @menu = create_menu
  end

  def show
    @params = permit_params
    render_404 unless code?
    @chapter = Chapter.includes(novel: :site).where(novel_id: @params[:novel_id]).find(@params[:chapter_id])
    @menu = create_menu
  end

  private

  def permit_params
    params.permit(:code, :novel_id, :chapter_id)
  end

  def code?
    Site.all_cached.exists?(code: @params[:code])
  end

  def create_menu
    if @params[:chapter_id].present?
      chapter = Chapter.find(@params[:chapter_id])[:chapter]
      previous_page = Chapter.previous(@params[:novel_id], chapter) || nil
      next_page = Chapter.next(@params[:novel_id], chapter) || nil
      { previous: previous_page, next: next_page }
    else
      { previous: nil, next: nil }
    end
  end

  def render_404
    @error = { status: 404, message: t('server_errors.defaults.status404') }
    render status: :not_found, template: 'errors/error'
  end

  def render_500
    @error = { status: 500, message: t('server_errors.defaults.status500') }
    render status: :internal_server_error, template: 'errors/error'
  end
end
