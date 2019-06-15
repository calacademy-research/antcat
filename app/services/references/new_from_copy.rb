module References
  class NewFromCopy
    include Service

    def initialize original
      @original = original
    end

    def call
      new_reference = original.class.new
      original.send :copy_attributes_to, new_reference, *to_copy
      new_reference
    end

    private

      attr_reader :original

      def to_copy
        type_specific_fields.concat basic_fields_and_notes
      end

      def type_specific_fields
        case original
        when ::ArticleReference then [:series_volume_issue, :journal_id]
        when ::BookReference    then [:publisher_id]
        when ::NestedReference  then [:pages_in, :nesting_reference_id]
        when ::UnknownReference then [:citation]
        else                         []
        end
      end

      def basic_fields_and_notes
        [
          :author_names_string_cache,
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
