# frozen_string_literal: true

class SiteController < ApplicationController
  include CommonActions
  before_action :set_sites

  def top
    @notifications = Novel.includes(:site).limit(50).reorder('novels.updated_at desc')
  end

  def index
    @params = permit_params
    render_404 unless code?
    @novel = Novel.includes(:site, :chapters).where(id: @params[:novel_id], sites: { code: @params[:code] }).first
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
end
