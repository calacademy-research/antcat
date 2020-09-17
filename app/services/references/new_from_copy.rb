# frozen_string_literal: true

module References
  class NewFromCopy
    include Service

    attr_private_initialize :original

    def call
      new_reference = original.class.new
      new_reference.attributes = original.slice(to_copy)
      new_reference
    end

    private

      def to_copy
        type_specific_fields.concat basic_fields_and_notes
      end

      def type_specific_fields
        case original
        when ::ArticleReference then [:series_volume_issue, :journal_id]
        when ::BookReference    then [:publisher_id]
        when ::NestedReference  then [:nesting_reference_id]
        else                         raise 'unknown type'
        end
      end

      def basic_fields_and_notes
        [
          :author_names_string_cache,
          :year,
          :year_suffix,
          :stated_year,
          :title,
          :pagination,
          :public_notes,
          :editor_notes,
          :taxonomic_notes
        ]
      end
  end
end
