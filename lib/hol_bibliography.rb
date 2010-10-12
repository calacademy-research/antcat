class HolBibliography

  NO_ENTRIES_FOR_AUTHOR = 1

  def initialize
    @scraper = Scraper.new
  end

  def match target_reference
    result = {}
    author_name = target_reference.authors.first.last_name
    year_match = false
    references = references_for(author_name)
    unless references.present?
      result[:status] = NO_ENTRIES_FOR_AUTHOR
    else
      references.each do |reference|
        year_match = year_match || target_reference.year == reference[:year]
        if target_reference.year == reference[:year] &&
          target_reference.series_volume_issue == reference[:series_volume_issue] &&
          target_reference.pagination == reference[:pagination]
          result[:source_url] = reference[:source_url]
          break
        end
      end
    end
    result
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
    id = li.at_css('strong').content.to_i
    reference[:source_url] = "http://antbase.org/ants/publications/#{id}/#{id}.pdf"
    parse_article(li, reference) || parse_book(li, reference) || lll{'li.content'}
  end

  def parse_article li, reference
    return unless second_strong = li.css('strong')[1]
    reference[:year] = second_strong.previous.content.match(/\d+/m).to_s.to_i or return
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

  def search_for_author author
    author_string = Iconv.conv 'ISO-8859-1', 'UTF-8', author 
    @scraper.get "http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=#{CGI.escape author_string}"
  rescue Iconv::IllegalSequence => e
    lll "Got an Iconv::IllegalSequence exception on [#{author}]"
    Nokogiri::HTML ''
  end

end
