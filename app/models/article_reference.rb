class ArticleReference < Reference
  belongs_to :journal

  validates_presence_of :journal, :series_volume_issue, :pagination

  def self.import base_class_data, data
    ArticleReference.create! base_class_data.merge(
      :series_volume_issue => data[:series_volume_issue],
      :pagination => data[:pagination],
      :journal => Journal.import(data[:journal])
    )
  end

  def start_page
    page_parts[:start]
  end

  def end_page
    page_parts[:end]
  end

  def series
    series_volume_issue_parts[:series]
  end

  def volume
    series_volume_issue_parts[:volume]
  end

  def issue
    series_volume_issue_parts[:issue]
  end

  private

  def series_volume_issue_parts
    @series_volume_issue_parts ||= ArticleCitationParser.get_series_volume_issue_parts series_volume_issue
  end

  def page_parts
    @page_parts ||= ArticleCitationParser.get_page_parts pagination
  end

end
