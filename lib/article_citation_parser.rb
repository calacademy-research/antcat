module ArticleCitationParser

  def self.parse string
    return unless string.present?

    begin
      parse = ArticleCitationGrammar.parse(string).value
    rescue Citrus::ParseError
      return
    end

    pagination = parse[:pagination]
    rest = parse[:journal_title_series_volume_issue]
    series_volume_issue = parse_series_volume_issue rest
    journal_title = rest.strip

    {:article => {:journal => journal_title, :series_volume_issue => series_volume_issue, :pagination => pagination}}
  end

  def self.parse_series_volume_issue string
    series_volume_issue_start = nil
    pos = series_volume_issue_end = string.length - 1
    loop do
      candidate = string[pos..series_volume_issue_end]
      begin
        result = SeriesVolumeIssueGrammar.parse string[pos..series_volume_issue_end]
        series_volume_issue_start = pos if result == candidate
      rescue
      end
      pos -= 1
      break if pos <  0
    end

    range = series_volume_issue_start..series_volume_issue_end
    series_volume_issue = string[range]
    string[range] = ''
    series_volume_issue
  end

  def self.get_series_volume_issue_parts string
    parts = {}
    return parts unless string
    matches = string.match(/(\(\w+\))?(\w+)(\(\w+\))?/) or return parts
    parts[:series] = matches[1].match(/\((\w+)\)/)[1] if matches[1].present?
    parts[:volume] = matches[2]
    parts[:issue] = matches[3].match(/\((\w+)\)/)[1] if matches[3].present?
    parts
  end

  def self.get_page_parts string
    parts = {}
    return parts unless string
    matches = string.match(/(.+?)(?:-(.+?))?\.?$/) or return parts
    parts[:start] = matches[1]
    parts[:end] = matches[2] if matches[2].present?
    parts
  end

end
