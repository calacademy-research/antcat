class HolBibliography

  NO_ENTRIES_FOR_AUTHOR = 1

  def initialize
    @scraper = Scraper.new
  end

  def match target_reference
    result = {}
    author_name = target_reference.authors.first.last_name
    references = references_for(author_name)
    unless references.present?
      result[:status] = NO_ENTRIES_FOR_AUTHOR
    else
      references.each do |reference|
        if target_reference.year == reference[:year]
          break if match_series_volume_issue_pagination target_reference, reference, result
          break if match_title target_reference, reference, result
        end
      end
    end
    result
  end

  def match_series_volume_issue_pagination target_reference, reference, result
    if target_reference.series_volume_issue == reference[:series_volume_issue] &&
       target_reference.pagination == reference[:pagination]
      result[:source_url] = reference[:source_url]
      return true
    end
    false
  end

  def match_title target_reference, reference, result
    if target_reference.title.present? && reference[:title].present? &&
       target_reference.title.gsub(/\W/, '') == reference[:title].gsub(/\W/, '')
      result[:source_url] = reference[:source_url]
      return true
    end
    false
  end

  def references_for author_name
    if author_name != @author_name
      @author_name = author_name
      @references = read_references author_name
    end
    @references
  end

  def read_references author_name
    doc = search_for_author author_name
    doc.css('li').inject([]) do |references, li|
      references << parse_reference(li)
    end
  end

  def parse_reference li
    reference = {}
    reference[:source_url] = parse_source_url li
    parse_article(li, reference) || parse_book(li, reference) || puts("\n\n#{li.content}\n\n")
  end

  def parse_source_url li
    text = li.inner_html
    match = text.match /or download \n\s+<a href="(.*?)"/m
    return match[1] if match
    id = li.at_css('strong').content.to_i
    "http://antbase.org/ants/publications/#{id}/#{id}.pdf"
  end

  def parse_article li, reference
    return unless second_strong = li.css('strong')[1]
    year_title_citation = (second_strong.previous.content + second_strong.content + second_strong.next.content).dup
    matches = year_title_citation.match /(\d+)\.\s*(.*)\n/m 
    return unless matches && matches.size == 3
    parse = TitleAndCitationParser.parse(matches[2])
    reference[:title] = parse[:title]
    reference[:year] = matches[1].to_i
    reference[:series_volume_issue] = parse[:citation][:article][:series_volume_issue]
    reference[:pagination] = parse[:citation][:article][:pagination]
    reference
  rescue
    nil
  end

  def parse_book li, reference
    reference[:year] = li.content.match(/^ (\d{4})\./m)[1].to_i or return
    reference[:pagination] = li.content.match(/\. (\d+ pp\.)/m)[1] or return
    reference
  rescue
    nil
  end

  def search_for_author author
    author_string = Iconv.conv 'ISO-8859-1', 'UTF-8', author 
    @scraper.get "http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=#{CGI.escape author_string}"
  rescue Iconv::IllegalSequence
    Rails.logger.info "Got an Iconv::IllegalSequence exception on [#{author}]"
    Nokogiri::HTML ''
  end

end
