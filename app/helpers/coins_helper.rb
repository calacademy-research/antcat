# coding: UTF-8
module CoinsHelper
  def coins reference
    klass = reference.to_class 'CoinsHelper'
    title = klass.new(reference).coins
    content_tag(:span, "", :class => "Z3988", :title => raw(title.join("&amp;")))
  end
end

class CoinsHelperBase
  def initialize reference
    @reference = reference
  end

  def coins
    @title = ["ctx_ver=Z39.88-2004"]
    @title << "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A#{kind}"
    @title << "rfr_id=antcat.org"
    @title << "rft.genre=#{genre}"
    add_contents
    @title << "rft.date=#{@reference.year}"
    @title.concat author_names
  end

  private
  def add tag, value
    @title << "#{tag}=#{treat(value)}" if value
  end

  def treat string
    CGI::escape(string.gsub(/[|*]/, ''))
  end

  def author_names
    @reference.author_names.inject([]) do |author_names, author|
      first_name_and_initials = author.first_name_and_initials
      last_name = author.last_name
      if first_name_and_initials && last_name
        author_names << "rft.aulast=#{treat last_name}"
        author_names << "rft.aufirst=#{treat first_name_and_initials}"
      else
        author_names << "rft.au=#{treat last_name}"
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
    add 'rft.jtitle', @reference.journal.name
    add 'rft.volume', @reference.volume
    add 'rft.issue', @reference.issue
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
    add 'rft.pub', @reference.publisher.name
    add 'rft.place', @reference.publisher.place.name
    add 'rft.pages', @reference.pagination
  end
end

class UnknownCoinsHelper < CoinsHelperBase
  def kind
    'dc'
  end
  def genre
    ''
  end
  def add_contents
    add 'rft.title', @reference.title
    add 'rft.source', @reference.citation
  end
end

class NestedCoinsHelper < CoinsHelperBase
  def kind
    'dc'
  end
  def genre
    ''
  end
  def add_contents
    add 'rft.title', @reference.title
  end
end
