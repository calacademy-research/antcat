# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithoutBoltonKeys < DatabaseScript
    LIMIT = 500

    def statistics
      "Results: #{references_without_bolton_keys.count} (showing first #{LIMIT})"
    end

    def results
      references_without_bolton_keys.order_by_author_names_and_year.limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'ID', 'Reference', 'Type'
        t.rows do |reference|
          [
            reference.id,
            link_to(reference.key_with_suffixed_year, reference_path(reference)),
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
tags: [slow-render]

issue_description:

description: >
  Issue: %github443

related_scripts:
  - ReferencesWithoutBoltonKeys
