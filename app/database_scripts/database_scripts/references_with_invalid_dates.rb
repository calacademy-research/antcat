# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithInvalidDates < DatabaseScript
    def results
      Reference.where.not("date REGEXP '#{ReferenceDateFormatValidator::VALID_FORMAT_REGEX_MYSQL}'")
    end

    def render
      as_table do |t|
        t.header 'Reference', 'Date', 'Formatted date'
        t.rows do |reference|
          [
            reference_link(reference),
            reference.date,
            References::FormatDate[reference.date]
          ]
        end
      end
    end
  end
end

__END__

section: misc
tags: [new!, references]

description: >

related_scripts:
  - ReferencesWithInvalidDates
