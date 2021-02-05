# frozen_string_literal: true

module PaperTrail
  class VersionDecorator < Draper::Decorator
    COMPACT_CHANGESET_HIDDEN_ITEM_TYPES = %w[
      Activity
    ]
    COMPACT_CHANGESET_HIDDEN_ATTRIBUTES = %w[
      created_at
      updated_at
    ]

    delegate :item_type, :item_id, :activity

    def revision_history_link
      return unless (url = RevisionHistoryPath[item_type, item_id])
      h.link_to "History", url, class: "btn-normal btn-tiny"
    end

    def activity_link
      return unless activity
      helpers.link_to 'Activity', activity, class: "btn-normal btn-tiny"
    end

    def format_changeset
      JSON.pretty_generate(object.changeset)
    end

    def format_compact_changeset
      return helpers.ndash if object.item_type.in?(COMPACT_CHANGESET_HIDDEN_ITEM_TYPES)
      JSON.pretty_generate(compact_changeset)
    end

    private

      def compact_changeset
        object.changeset.except(*COMPACT_CHANGESET_HIDDEN_ATTRIBUTES)
      end
  end
end
