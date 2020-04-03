# frozen_string_literal: true

# TODO: (not very important) Series, volume and issue could be stored in their own columns.

class ArticleReference < Reference
  belongs_to :journal

  validates :series_volume_issue, :pagination, presence: true

  # TODO: Not used (since at least December 2016).
  def series
    series_volume_and_issue_parts[:series]
  end

  def volume
    series_volume_and_issue_parts[:volume]
  end

  def issue
    series_volume_and_issue_parts[:issue]
  end

  private

    def series_volume_and_issue_parts
      @_series_volume_and_issue_parts ||= References::ExtractSeriesVolumeAndIssue[series_volume_issue]
    end
end
