module CoinsHelper
  def coins reference
    title = case reference.reference
    when ArticleReference then ArticleCoinsHelper
    when BookReference then BookCoinsHelper
    else raise "Don't know what kind of reference this is: #{reference.reference.inspect}"
    end.new(reference).coins

    content_tag(:span, "", :class => "Z3988", :title => title.join("&amp;"))
  end
end

class CoinsHelperBase
  def initialize ward_reference
    @source = ward_reference.reference.source
  end

  def coins
    @title = ["ctx_ver=Z39.88-2004"]
    @title << "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A#{kind}"
    @title << "rfr_id=antcat.org"
    @title << "rft.genre=#{genre}"
    add_contents
    @title << "rft.date=#{@source.year}"
    @title.concat authors
  end

  private
  def add tag, value
    @title << "#{tag}=#{treat(value)}" if value
  end

  def treat string
    CGI::escape(string.gsub(/[|*]/, ''))
  end

  def authors
    @source.authors.inject([]) do |authors, author|
      name = author.name
      parts = name.match(/(.*?), (.*)/)
      unless parts
        authors << "rft.au=#{treat(name)}"
      else
        authors << "rft.aulast=#{treat(parts[1])}" if parts[1]
        authors << "rft.aufirst=#{treat(parts[2])}" if parts[2]
      end
    end
  end
end

class ArticleCoinsHelper < CoinsHelperBase
  def kind
    'journal'
  end
  def genre
    'article'
  end
  def add_contents
    add 'rft.atitle', @source.title
    add 'rft.jtitle', @source.issue.journal.title
    add 'rft.volume', @source.issue.volume
    add 'rft.issue', @source.issue.issue
    add 'rft.spage', @source.start_page
    add 'rft.epage', @source.end_page
  end
end

class BookCoinsHelper < CoinsHelperBase
  def kind
    'book'
  end
  def genre
    'book'
  end
  def add_contents
    add 'rft.btitle', @source.title
    add 'rft.pub', @source.publisher
    add 'rft.place', @source.place
    add 'rft.pages', @source.pagination
  end
end
