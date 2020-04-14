# frozen_string_literal: true

module DatabaseScripts
  class CitationYearsWithExtras < DatabaseScript
    def results
      Reference.where("citation_year NOT REGEXP ?", "^[0-9][0-9][0-9][0-9][a-z]?$")
    end

    def render
      as_table do |t|
        t.header 'Reference', 'citation_year', 'Extras', 'Diff', 'Standard format?'
        t.rows do |reference|
          standard_format = reference.citation_year.match?(/^\d\d\d\d[a-zA-Z]?( \("\d\d\d\d"\))$/)
          extra_year = reference.citation_year.scan(/"([^"]*)"/)&.first&.first
          year_diff = if standard_format && extra_year.to_i != 0
                        reference.citation_year.to_i - extra_year.to_i
                      end
          [
            link_to(reference.keey, reference_path(reference)),
            reference.citation_year,
            extra_year,
            year_diff,
            ('No' unless standard_format)
          ]
        end
      end
    end
  end
end

__END__

title: <code>citation_year</code>s with extras

section: pa-no-action-required
category: References
tags: [slow-render, new!]

description: >
  Once confirmed, the plan is to move the "extras" into a new database column.

related_scripts:
  - CitationYearsWithExtras
  - CitationYearsWithUppercaseLetters
