# coding: UTF-8
class ArticleReference < UnmissingReference
  belongs_to :journal

  validates_presence_of :journal, :series_volume_issue, :pagination

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
