module CoinsHelper
  def coins reference
    @reference = reference
    @title = ["ctx_ver=Z39.88-2004"]
    @title << "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A#{@reference.kind}"
    @title << "rfr_id=antcat.org"
    @title << "rft.genre=" +
            case @reference.kind
            when 'journal': 'article'
            when 'book': 'book'
            else ''
            end
    case @reference.kind
    when'journal'
      add_journal
    when 'book'
      add_book
    end
    @title << "rft.date=#{@reference.numeric_year}" if @reference.numeric_year

    @title.concat authors if @reference.authors.present?

    content_tag(:span, "", :class => "Z3988", :title => @title.join("&amp;"))
  end

  private
  def add_journal
    add 'rft.atitle', @reference.title
    add 'rft.jtitle', @reference.journal_title
    add 'rft.volume', @reference.volume
    add 'rft.issue', @reference.issue
    add 'rft.spage', @reference.start_page
    add 'rft.epage', @reference.end_page
  end

  def add_book
    add 'rft.btitle', @reference.title
    add 'rft.pub', @reference.publisher
    add 'rft.place', @reference.place
    add 'rft.pages', @reference.pagination
  end

  def add tag, value
    @title << "#{tag}=#{treat(value)}" if value
  end

  def authors
    authors = @reference.authors.split(/; ?/)
    authors.inject([]) do |authors, author|
      parts = author.match(/(.*?), (.*)/)
      unless parts
        authors << "rft.au=#{treat(author)}"
      else
        authors << "rft.aulast=#{treat(parts[1])}" if parts[1]
        authors << "rft.aufirst=#{treat(parts[2])}" if parts[2]
      end
    end
  end
  
  def treat string
    CGI::escape(string.gsub(/[|*]/, ''))
  end
end
