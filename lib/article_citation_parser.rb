module ArticleCitationParser

  def self.parse string
    return unless string.present?
    matches = string.match(/(.+?)(\S+)$/) or return
    journal_title = matches[1].strip

    return if string =~ /^[a-z]/

    matches = matches[2].match /(.+?):(.+)$/
    return unless matches
    series_volume_issue = matches[1]
    pages = ReferenceParser.remove_period_from matches[2]

    {:article => {:journal => journal_title, :series_volume_issue => series_volume_issue, :pagination => pages}}
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
