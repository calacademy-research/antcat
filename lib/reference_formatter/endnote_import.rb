class ReferenceFormatter::EndnoteImport
  def self.format references
    references.map do |reference|
      klass = case reference
      when ArticleReference then ReferenceFormatter::EndnoteImport::Article
      when BookReference then ReferenceFormatter::EndnoteImport::Book
      when NestedReference then ReferenceFormatter::EndnoteImport::Nested
      when UnknownReference then ReferenceFormatter::EndnoteImport::Unknown
      else raise "Don't know what kind of reference this is: #{reference.inspect}"
      end
      klass.new(reference).format
    end.join("\n") + "\n"
  end
end

class ReferenceFormatter::EndnoteImport::Base
  def initialize reference
    @reference = reference
    @string = []
  end

  def format
    add_author_names
    add_contents
    @string.join("\n") + "\n"
  end

  private
  def add tag, value
    @string << "%#{tag} #{value}" if value
  end

  def add_author_names
    for author in @reference.author_names
      add "A", author.name
    end
  end

end

class ReferenceFormatter::EndnoteImport::Article < ReferenceFormatter::EndnoteImport::Base
  def kind
    'journal'
  end
  def genre
    'article'
  end
  def add_contents
    add 'T', @reference.title
    #add 'rft.jtitle', @reference.journal.name
    #add 'rft.volume', @reference.volume
    #add 'rft.issue', @reference.issue
    #add 'rft.spage', @reference.start_page
    #add 'rft.epage', @reference.end_page
  end
end

class ReferenceFormatter::EndnoteImport::Book < ReferenceFormatter::EndnoteImport::Base
  def kind
    'book'
  end
  def genre
    'book'
  end
  def add_contents
    add 'T', @reference.title
    #add 'rft.pub', @reference.publisher.name
    #add 'rft.place', @reference.publisher.place.name
    #add 'rft.pages', @reference.pagination
  end
end

class ReferenceFormatter::EndnoteImport::Unknown < ReferenceFormatter::EndnoteImport::Base
  def kind
    'dc'
  end
  def genre
    ''
  end
  def add_contents
    add 'T', @reference.title
    #add 'rft.source', @reference.citation
  end
end

class ReferenceFormatter::EndnoteImport::Nested < ReferenceFormatter::EndnoteImport::Base
  def kind
    'dc'
  end
  def genre
    ''
  end
  def add_contents
    add 'T', @reference.title
  end
end
