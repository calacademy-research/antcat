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

    # Selected classes from:
    # ```
    # PaperTrail::Version.where(item_type: %w[Name Reference Taxon]).where.not(object: nil).pluck(:item_type, :object).
    #   map { |item_type, object| [item_type, object[/type:[ -\\n]+\w+/]] }.tally.
    #   sort_by { |(item_type, type), count| [item_type, (type || "_"), count] }
    # ```
    SAFE_REIFY_STI_CLASSES = [
      ['Name',      'CollectiveGroupName'],
      ['Name',      'FamilyOrSubfamilyName'],
      ['Reference', 'MissingReference'],
      ['Reference', 'UnknownReference']
    ]

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
    scope :chronological, -> { order(created_at: :asc, id: :asc) }

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

    # HACK: To fix "The single-table inheritance mechanism failed to locate the subclass: 'MissingReference'".
    # Examples: http://localhost:3000/references/141884/history, http://localhost:3000/names/134043/history
    # This was written mostly for fun - if it causes extra work in the future, consider just removing it since it's not that important.
    def safe_reify
      reify
    rescue ActiveRecord::SubclassNotFound
      raise unless monkey_patch_safe_reify?

      # https://github.com/paper-trail-gem/paper_trail/blob/1fe26c9e445b0bcb2f7c20a5791ec01003632517/lib/paper_trail/reifier.rb#L132
      def self.object_deserialized # rubocop:disable Lint/NestedMethodDefinition
        super.dup.tap do |hsh|
          hsh['type'] = item_type
        end
      end

      retry
    end

    private

      def monkey_patch_safe_reify?
        return false if singleton_methods.include?(:object_deserialized)
        [item_type, object_deserialized['type']].in?(SAFE_REIFY_STI_CLASSES)
      end
  end
end
