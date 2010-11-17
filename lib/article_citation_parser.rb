module ArticleCitationParser

  def self.parse string, possibly_embedded
    return unless string.present?

    begin
      parse = ArticleCitationGrammar.parse(string).value
    rescue Citrus::ParseError
      return
    end

    pagination = parse[:pagination]
    rest = parse[:journal_name_series_volume_issue]
    series_volume_issue = parse_series_volume_issue rest
    journal_name = rest.strip

    return unless journal_name?(journal_name, possibly_embedded)

    {:article => {:journal => journal_name, :series_volume_issue => series_volume_issue, :pagination => pagination}}
  end

  def self.parse_series_volume_issue string
    pos = series_volume_issue_end = string.length - 1

    begin
      candidate = string[pos..series_volume_issue_end]
      begin
        result = SeriesVolumeIssueStringGrammar.parse(string[pos..series_volume_issue_end] + ':')
        string.gsub! /#{Regexp.escape result[0..-2]}/, ''
        return result.value
      rescue
      end
    end until (pos -= 1) <  0
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

  private
  def self.journal_name? string, possibly_embedded
    return true unless possibly_embedded
    string.index('.').nil? || starts_with_common_first_word_of_journal_name?(string) || Journal.find_by_name(string)
  end

  def self.starts_with_common_first_word_of_journal_name? string
    string =~ /^(Abhandlungen|Acta|Actes|Anales|Annalen|Annales|Annali|Annals|Archives|Archivos|Arquivos|Boletim|Boletin|Bollettino|Bulletin|Izvestiya|Journal|Memoires|Memoirs|Memorias|Memorie|Mitteilungen|Occasional Papers)|Revista|Revue/
  end

end
