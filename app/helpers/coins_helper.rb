module CoinsHelper
  def coins reference
    title = case reference.reference
    when ArticleReference then ArticleCoinsHelper
    when BookReference then BookCoinsHelper
    else return '' #raise "Don't know what kind of reference this is: #{reference.reference.inspect}"
    end.new(reference).coins

    content_tag(:span, "", :class => "Z3988", :title => title.join("&amp;"))
  end
end

class CoinsHelperBase
  def initialize reference
    @reference = reference.reference
  end

  def coins
    @title = ["ctx_ver=Z39.88-2004"]
    @title << "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A#{kind}"
    @title << "rfr_id=antcat.org"
    @title << "rft.genre=#{genre}"
    add_contents
    @title << "rft.date=#{@reference.year}"
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
    @reference.authors.inject([]) do |authors, author|
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
    add 'rft.atitle', @reference.title
    add 'rft.jtitle', @reference.issue.journal.title
    add 'rft.volume', @reference.issue.volume
    add 'rft.issue', @reference.issue.issue
    add 'rft.spage', @reference.start_page
    add 'rft.epage', @reference.end_page
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
    add 'rft.btitle', @reference.title
    add 'rft.pub', @reference.publisher
    add 'rft.place', @reference.place
    add 'rft.pages', @reference.pagination
  end
end
