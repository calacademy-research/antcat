# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithDisagreeingYearAndDate < DatabaseScript
    def results
      Reference.where.not("date REGEXP CONCAT('^', year)")
    end

    def render
      as_table do |t|
        t.header 'Reference', 'Date', 'Formatted date', 'Year'
        t.rows do |reference|
          [
            reference_link(reference),
            reference.date,
            References::FormatDate[reference.date],
            reference.year
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
tags: [references, disagreeing-data]

related_scripts:
  - ReferencesWithDisagreeingYearAndDate
