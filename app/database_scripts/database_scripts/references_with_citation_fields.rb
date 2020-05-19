# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithCitationFields < DatabaseScript
    def results
      Reference.where.not(citation: ['', nil]).
        order_by_author_names_and_year.
        includes(:author_names).references(:reference_author_names)
    end

    def render
      as_table do |t|
        t.header 'Reference', 'citation', 'Expanded reference'
        t.rows do |reference|
          [
            link_to(reference.keey, reference_path(reference)),
            reference.citation,
            reference.decorate.expanded_reference
          ]
        end
      end
    end
  end
end

__END__

title: References with <code>citation</code> fields

section: pa-action-required
category: References
tags: [new!]

description: >
  To be cleared by script once confirmed.


  These are relics from the time the `citation` column was used for `MissingReference`s and `UknownReference`s.

related_scripts:
  - ReferencesWithCitationFields
