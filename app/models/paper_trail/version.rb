# frozen_string_literal: true

module PaperTrail
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern
    include SetRequestUuid

    belongs_to :activity, optional: true, foreign_key: :request_uuid, primary_key: :request_uuid

    scope :filter_where, ->(filter_params) do
      results = where(nil)
      filter_params.each do |key, value|
        results = results.where(key => value) if value.present?
      end
      results
    end
    scope :without_user_versions, -> { where.not(item_type: "User") }

    def self.search search_query, search_type
      search_type = search_type.presence || 'LIKE'

      case search_type
      when 'LIKE'
        where('object LIKE :q OR object_changes LIKE :q', q: "%#{search_query}%")
      when 'REGEXP'
        where('object REGEXP :q OR object_changes REGEXP :q', q: search_query)
      else
        raise "unknown search_type #{search_type}"
      end
    end

    def user
      User.find(whodunnit) if whodunnit
    end
  end
end
