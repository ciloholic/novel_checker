# frozen_string_literal: true

module CacheSupport
  extend ActiveSupport::Concern

  included do
    class << self
      def all_cached
        Rails.cache.fetch("cached_#{name.underscore}s", expired_in: 1.hour) { all.load }
      end
    end

    after_commit :flush_cache

    private

    def flush_cache
      Rails.cache.delete("cached_#{self.class.name.underscore}s")
    end
  end
end
