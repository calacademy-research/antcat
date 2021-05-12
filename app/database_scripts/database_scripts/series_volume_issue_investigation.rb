# frozen_string_literal: true

module DatabaseScripts
  class SeriesVolumeIssueInvestigation < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

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
            reference_link(reference),
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
tags: [references]

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
