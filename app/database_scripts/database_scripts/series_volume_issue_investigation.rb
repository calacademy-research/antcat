# frozen_string_literal: true

module DatabaseScripts
  class SeriesVolumeIssueInvestigation < DatabaseScript
    def results
      ArticleReference.
        limit(10000).
        where("series_volume_issue NOT REGEXP ?", "^[0-9]+$").                  # 12
        where("series_volume_issue NOT REGEXP ?", "^[0-9]+-[0-9]+$").           # 12-34
        where("series_volume_issue NOT REGEXP ?", "^[0-9]+\\([0-9]+\\)$").      # 12(34)
        where("series_volume_issue NOT REGEXP ?", "^[0-9]+ \\([0-9]+\\)$").     # 12 (34)
        where("series_volume_issue NOT REGEXP ?", "^\\([0-9]+\\)[0-9]+$").      # (12)34
        where("series_volume_issue NOT REGEXP ?", "^[0-9]+\\([0-9]+\\)$[0-9]+") # 12(34)56
    end

    def render
      as_table do |t|
        t.header 'Reference', 'series_volume_issue'
        t.rows do |reference|
          [
            link_to(reference.key_with_citation_year, reference_path(reference)),
            reference.series_volume_issue
          ]
        end
      end
    end
  end
end

__END__

title: <code>series_volume_issue</code> investigation

section: research
category: References
tags: []

issue_description:

description: >
  Excluded formats:


  * 12

  * 12-34

  * 12(34)

  * 12 (34)

  * (12)34

  * 12(34)56

related_scripts:
  - SeriesVolumeIssueInvestigation
