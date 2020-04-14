# frozen_string_literal: true

module DatabaseScripts
  class NestedReferencesWithNestedReferences < DatabaseScript
    def results
      NestedReference.where(nesting_reference_id: NestedReference.select(:id))
    end

    def render
      as_table do |t|
        t.header 'Nested reference', '...in (another nested reference)', '...in'
        t.rows do |reference|
          nesting_reference = reference.nesting_reference
          second_nesting_reference = nesting_reference.try :nesting_reference

          [
            reference_link(reference),
            reference_link(nesting_reference),
            reference_link_with_type(second_nesting_reference)
          ]
        end
      end
    end

    private

      def reference_link reference
        link_to(reference.keey, reference_path(reference)) + ' ' + reference.pagination
      end

      def reference_link_with_type reference
        return unless reference
        reference_link(reference) + ' ' + reference.type
      end
  end
end

__END__

section: research
category: References
tags: [list, new!]

description: >
  This is not an issue. The script was added to get an overview of how many such cases we have.

related_scripts:
  - NestedReferencesWithNestedReferences
