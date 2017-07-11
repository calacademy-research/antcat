module References
  class NewFromCopy
    def initialize original
      @original = original
    end

    def call
      new_reference = original.class.new # Build correct type.

      # Type-specific fields.
      to_copy = case original
                when ::ArticleReference then [:series_volume_issue]
                when ::NestedReference  then [:pages_in, :nesting_reference_id]
                when ::UnknownReference then [:citation]
                else                       []
                end

      # Basic fields and notes.
      to_copy.concat [ :author_names_string,
                       :citation_year,
                       :title,
                       :pagination,
                       :public_notes,
                       :editor_notes,
                       :taxonomic_notes ]

      # The two virtual attributes.
      if original.is_a?(::BookReference)
        new_reference.publisher_string = "#{publisher.place.name}: #{publisher.name}"
      end
      new_reference.journal_name = journal.name if original.is_a?(::ArticleReference)

      original.send :copy_attributes_to, new_reference, *to_copy
      new_reference
    end

    private
      attr_reader :original

      delegate :journal, :publisher, to: :original
  end
end
