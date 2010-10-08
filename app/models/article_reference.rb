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

  def citation_string
    Reference.add_period_if_necessary "#{journal.title} #{series_volume_issue}:#{pagination}"
  end

  def start_page
    parse_pagination
    @start_page
  end

  def end_page
    parse_pagination
    @end_page
  end

  def series
    parse_series_volume_issue
    @series
  end

  def volume
    parse_series_volume_issue
    @volume
  end

  def issue
    parse_series_volume_issue
    @issue
  end

  private
  def parse_pagination
    return unless pagination
    parts = pagination.match(/(.+?)(?:-(.+?))?\.?$/) or return
    @start_page = parts[1]
    @end_page = parts[2] if parts.length == 3
  end

  def parse_series_volume_issue
    return unless series_volume_issue
    parts = series_volume_issue.match(/(\(\w+\))?(\w+)(\(\w+\))?/) or return
    @series = parts[1].match(/\((\w+)\)/)[1] if parts[1].present?
    @volume = parts[2]
    @issue = parts[3].match(/\((\w+)\)/)[1] if parts[3].present?
  end

end
