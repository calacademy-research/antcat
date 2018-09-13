module References
  class NewFromCopy
    include Service

    def initialize original
      @original = original
    end

    def call
      new_reference = original.class.new # Build correct type.

      # The two virtual attributes.
      if original.is_a?(::BookReference)
        new_reference.publisher_string = "#{publisher.place_name}: #{publisher.name}"
      end
      new_reference.journal_name = journal.name if original.is_a?(::ArticleReference)

      original.send :copy_attributes_to, new_reference, *to_copy
      new_reference
    end

    private

      attr_reader :original

      delegate :journal, :publisher, to: :original

      def to_copy
        type_specific_fields.concat basic_fields_and_notes
      end

      def type_specific_fields
        case original
        when ::ArticleReference then [:series_volume_issue]
        when ::NestedReference  then [:pages_in, :nesting_reference_id]
        when ::UnknownReference then [:citation]
        else                         []
        end
      end

      def basic_fields_and_notes
        [
          :author_names_string,
          :citation_year,
          :title,
          :pagination,
          :public_notes,
          :editor_notes,
          :taxonomic_notes
        ]
      end
  end
end
