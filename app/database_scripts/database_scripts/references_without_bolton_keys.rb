# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithoutBoltonKeys < DatabaseScript
    def results
      references_without_bolton_keys.order_by_author_names_and_year.limit(1000)
    end

    def statistics
      "Results: #{references_without_bolton_keys.count} (showing first 1000)"
    end

    def render
      as_table do |t|
        t.header 'ID', 'Reference', 'Type'
        t.rows do |reference|
          [
            reference.id,
            link_to(reference.keey, reference_path(reference)),
            reference.type
          ]
        end
      end
    end

    private

      def references_without_bolton_keys
        Reference.where(bolton_key: nil)
      end
  end
end

__END__

title: References without <code>bolton_key</code>s

section: list
category: References
tags: [slow-render, new!]

issue_description:

description: >
  Issue: %github443

related_scripts:
  - ReferencesWithoutBoltonKeys
