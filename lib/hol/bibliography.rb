class Hol::Bibliography

  NO_ENTRIES_FOR_AUTHOR = 1

  def initialize
    @scraper = Scraper.new
  end

  def match target_reference
    result = {}
    author_name = target_reference.author_names.first.last_name
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
      result[:document_url] = reference[:document_url]
      return true
    end
    false
  end

  def match_title target_reference, reference, result
    if target_reference.title.present? && reference[:title].present? &&
       target_reference.title.gsub(/\W/, '') == reference[:title].gsub(/\W/, '')
      result[:document_url] = reference[:document_url]
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
    reference[:document_url] = parse_document_url li
    parse_article(li, reference) || parse_book(li, reference) || parse_other(li, reference)
  end

  def parse_document_url li
    text = li.inner_html
    match = text.match /or download\s+<a href="(.*?)"/
    return match[1] if match
    id = li.at_css('strong').content.to_i
    "http://antbase.org/ants/publications/#{id}/#{id}.pdf"
  end

  def parse_article li, reference
    return unless second_strong = li.css('strong')[1]
    year_title_journal = second_strong.previous.content
    start_of_title = year_title_journal.match(/\.?.*?\.\s+/m).end(0)
    last_period = year_title_journal.rindex '.'
    reference[:title] = year_title_journal[start_of_title..last_period - 1]
    reference[:year] = year_title_journal.match(/\d+/m).to_s.to_i or return
    reference[:series_volume_issue] = second_strong.content + second_strong.next.content.match(/(.*?):/)[1]
    reference[:pagination] = second_strong.next.content.match(/:\s*(.*)./)[1] or return
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

  def parse_other li, reference
    reference
  end

  def search_for_author author
    author_string = Iconv.conv 'ISO-8859-1', 'UTF-8', author
    @scraper.get "http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=#{CGI.escape author_string}"
  rescue Iconv::IllegalSequence
    Rails.logger.info "Got an Iconv::IllegalSequence exception on [#{author}]"
    Nokogiri::HTML ''
  end

end
