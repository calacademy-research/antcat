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
    end.select{|string| string.present?}.join("\n") + "\n"
  end
end

class ReferenceFormatter::EndnoteImport::Base
  def initialize reference
    @reference = reference
    @string = []
  end

  def format
    add '0', kind
    add_author_names
    add 'D', @reference.year
    add 'T', @reference.title
    add_contents
    add 'Z', @reference.public_notes
    add 'K', @reference.taxonomic_notes
    add 'U', @reference.url
    add '~', 'AntCat'
    @string.join("\n") + "\n"
  end

  private
  def add tag, value
    @string << "%#{tag} #{value.to_s.gsub(/[|*]/, '')}" if value.present?
  end

  def add_author_names
    for author in @reference.author_names
      add "A", author.name
    end
  end

end

class ReferenceFormatter::EndnoteImport::Article < ReferenceFormatter::EndnoteImport::Base
  def kind
    'Journal Article'
  end
  def add_contents
    add 'J', @reference.journal.name
    add 'N', @reference.series_volume_issue
    add 'P', @reference.pagination
  end
end

class ReferenceFormatter::EndnoteImport::Book < ReferenceFormatter::EndnoteImport::Base
  def kind
    'Book'
  end
  def add_contents
    add 'C', @reference.publisher.place.name
    add 'I', @reference.publisher.name
    add 'P', @reference.pagination
  end
end

class ReferenceFormatter::EndnoteImport::Unknown < ReferenceFormatter::EndnoteImport::Base
  def kind
    'Generic'
  end
  def add_contents
    add '1', @reference.citation
  end
end

class ReferenceFormatter::EndnoteImport::Nested < ReferenceFormatter::EndnoteImport::Base
  # don't know how to get EndNote to handle nested references
  def format
    ''
  end
end
