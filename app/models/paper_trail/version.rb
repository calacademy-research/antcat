# frozen_string_literal: true

module PaperTrail
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern
    include SetRequestUuid

    belongs_to :change

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
      raise unless search_type.in? ["LIKE", "REGEXP"]

      q = if search_type == "LIKE"
            "%#{search_query}%"
          else
            search_query
          end

      where(<<-SQL.squish, q: q)
        object #{search_type} :q OR object_changes #{search_type} :q
      SQL
    end

    def user
      User.find(whodunnit) if whodunnit
    end
  end
end
