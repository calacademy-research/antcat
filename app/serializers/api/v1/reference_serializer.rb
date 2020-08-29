# frozen_string_literal: true

module Api
  module V1
    class ReferenceSerializer
      ATTRIBUTES = [
        :id,
        :title,
        :year,
        :citation_year,
        :stated_year,
        :date,
        :doi,
        :online_early,
        :pagination,
        :review_state,
        :bolton_key,
        :author_names_suffix,

        # Type-specific.
        :journal_id,
        :publisher_id,
        :series_volume_issue,
        :nesting_reference_id,

        # Notes.
        :public_notes,
        :editor_notes,
        :taxonomic_notes,

        # Caches.
        :plain_text_cache,
        :author_names_string_cache,

        :created_at,
        :updated_at
      ]

      attr_private_initialize :reference

      def as_json _options = {}
        reference.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
