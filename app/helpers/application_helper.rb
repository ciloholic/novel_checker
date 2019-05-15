# frozen_string_literal: true

module ApplicationHelper
  def mobile?
    request.user_agent =~ /iPhone|iPad|Android/
  end
end
