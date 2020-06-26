# frozen_string_literal: true

module References
  module Concerns
    module Searchable
      extend ActiveSupport::Concern

      SOLR_IGNORE_ATTRIBUTE_CHANGES_OF = %i[
        plain_text_cache
        expandable_reference_cache
        expanded_reference_cache
      ]

      included do
        searchable(ignore_attribute_changes_of: SOLR_IGNORE_ATTRIBUTE_CHANGES_OF) do
          string(:type)
          integer(:year)
          text(:author_names_string)
          text(:author_names_string, as: :author_names_string_antcat_text)
          text(:citation_year)
          text(:stated_year)
          text(:title)
          # NOTE: Safe navigation for `.name` is for journals/publishers created at the same time as the reference.
          text(:journal_name) { journal&.name if respond_to?(:journal) }
          text(:publisher_name) { publisher&.name if respond_to?(:publisher) }
          text(:year_as_string) { year.to_s }
          text(:public_notes)
          text(:editor_notes)
          text(:taxonomic_notes)
          text(:bolton_key)
          text(:authors_for_key) { key.authors_for_key } # To find "et al".
          string(:citation_year)
          string(:stated_year)
          string(:doi)
          string(:author_names_string)
        end
      end
    end
  end
end
