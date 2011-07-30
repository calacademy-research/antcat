class Hol::Bibliography

  def initialize
    @scraper = Scraper.new
  end

  def read_references author_name
    doc = search_for_author author_name
    doc.css('li').inject([]) do |references, li|
      references << parse_reference(li, author_name)
    end
  end

  def parse_reference li, author_name
    reference = Hol::Reference.new :author => author_name
    reference.document_url = parse_document_url li
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
    reference.type = 'ArticleReference'
    reference.title = year_title_journal[start_of_title..last_period - 1]
    reference.year = year_title_journal.match(/\d+/m).to_s.to_i or return
    reference.series_volume_issue = second_strong.content + second_strong.next.content.match(/(.*?):/)[1]
    reference.pagination = second_strong.next.content.match(/:\s*(.*)./)[1] or return
    reference
  rescue
    nil
  end

  def parse_book li, reference
    reference.type = 'BookReference'
    reference.year = li.content.match(/^ (\d{4})\./m)[1].to_i or return
    reference.pagination = li.content.match(/\. (\d+ pp\.)/m)[1] or return
    reference
  rescue
    nil
  end

  def parse_other li, reference
    reference.type = 'OtherReference'
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
