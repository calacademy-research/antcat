class Views::Coins < Erector::Widget
  needs :reference

  def content
    title = ["ctx_ver=Z39.88-2004"]
    title << "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A#{@reference.kind}"
    title << "rfr_id=antcat.org"
    title << "rft.genre=" +
            case @reference.kind
            when 'journal': 'article'
            when 'book': 'book'
            else ''
            end
    case @reference.kind
    when'journal'
      title << "rft.atitle=#{treat @reference.title}" if @reference.title
      title << "rft.jtitle=#{treat @reference.short_journal_title}" if @reference.short_journal_title
      title << "rft.volume=#{treat @reference.volume}" if @reference.volume
      title << "rft.issue=#{treat @reference.issue}" if @reference.issue
      title << "rft.spage=#{treat @reference.start_page}" if @reference.start_page
      title << "rft.epage=#{treat @reference.end_page}" if @reference.end_page
    when 'book'
      title << "rft.btitle=#{treat @reference.title}" if @reference.title
      title << "rft.pub=#{treat @reference.publisher}" if @reference.publisher
      title << "rft.place=#{treat @reference.place}" if @reference.place
    end
    title << "rft.date=#{@reference.numeric_year}" if @reference.numeric_year

    title.concat authors if @reference.authors.present?

    span :class => "Z3988", :title => raw(title.join("&amp;"))
  end

  private
  def authors
    authors = @reference.authors.split(/; ?/)
    authors.inject([]) do |a,e|
      parts = e.match(/(.*?), (.*)/)
      unless parts
        a << "rft.au=#{treat(e)}"
      else
        a << "rft.aulast=#{treat(parts[1])}" if parts[1]
        a << "rft.aufirst=#{treat(parts[2])}" if parts[2]
      end
    end
  end
  
  def treat s
    s = s.gsub(/[|*]/, '')
    html_escape = CGI::escape(s)
    raw html_escape
  end
end
