# frozen_string_literal: true

module PaperTrail
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern
    include SetRequestUuid

    # As defined in PaperTrail. Copied here since they are not in the gem's source code.
    EVENTS = [
      CREATE = 'create',
      UPDATE = 'update',
      DESTROY = 'destroy'
    ]
    DEPRECATED_ITEM_TYPES = %w[Synonym TaxonState]
    HIDDEN_ITEM_TYPES = %w[User]

    belongs_to :activity, optional: true, foreign_key: :request_uuid, primary_key: :request_uuid
    belongs_to :user, optional: true, foreign_key: :whodunnit

    scope :filter_where, ->(filter_params) do
      results = where(nil)
      filter_params.each do |key, value|
        results = results.where(key => value) if value.present?
      end
      results
    end
    scope :base_scope, -> { without_deprecated_item_types.without_hidden }
    scope :without_deprecated_item_types, -> { where.not(item_type: DEPRECATED_ITEM_TYPES) }
    scope :without_hidden, -> { where.not(item_type: HIDDEN_ITEM_TYPES) }
    # TODO: Use this scope if it makes sense -- this most likely requires changes for how PaperTrail orders versions
    # internally (and add index on `versions.created_at`). Because IDs in the prod db are not ordered 100% chronologically.
    scope :oldest_last, -> { order(created_at: :desc, id: :desc) }

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
  end
end
