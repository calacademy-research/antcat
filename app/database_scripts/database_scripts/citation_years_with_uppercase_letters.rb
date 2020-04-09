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
category: References
tags: [list, new!]

description: >
  This list was added to get an overview of `citation_year`s.


  Uppercase letters can be changed by script, so we do not have to spend on time fixing them manually.

related_scripts:
  - CitationYearsWithUppercaseLetters
