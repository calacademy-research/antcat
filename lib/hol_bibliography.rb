class HolBibliography
  def initialize
    @scraper = Scraper.new
  end

  def match reference
    author_name = reference.authors.first.last_name
    best_match = nil
    references_for(author_name).each do |hol_reference|
      best_match = hol_reference
      break
      # if positive match, break
      # if better match than any others so far, save it
    end
    best_match
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
    {:authors => ['Fisher, B.L.'], :title => 'title', :year => '2010'}
  end

  def search_for_author author
    @scraper.get "http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=#{author}"
  end

end
