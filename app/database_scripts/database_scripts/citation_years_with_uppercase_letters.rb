# frozen_string_literal: true

module DatabaseScripts
  class CitationYearsWithUppercaseLetters < DatabaseScript
    def results
      Reference.order_by_author_names_and_year.where("BINARY citation_year REGEXP ?", "[A-Z]")
    end

    def render
      as_table do |t|
        t.header 'Reference', 'Citation year'
        t.rows do |reference|
          [
            link_to(reference.keey, reference_path(reference)),
            reference.citation_year
          ]
        end
      end
    end
  end
end

__END__

title: <code>citation_year</code>s with uppercase letters

section: pa-no-action-required
category: References
tags: [new!]

description: >
  Uppercase letters will be changed to lowercase by script.

related_scripts:
  - CitationYearsWithExtras
  - CitationYearsWithUppercaseLetters
