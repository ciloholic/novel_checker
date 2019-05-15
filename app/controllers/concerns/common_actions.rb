# frozen_string_literal: true

module CommonActions
  extend ActiveSupport::Concern
  def set_sites
    @sites = Site.published.reorder('sites.sort asc, novels.code asc')
  end

  def set_novels
    @novel = Novel.includes(:site, :chapters).where(id: @params[:novel_id], sites: { code: @params[:code] }).first
  end
end
