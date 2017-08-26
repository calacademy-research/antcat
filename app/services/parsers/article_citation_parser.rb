module Parsers::ArticleCitationParser
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
