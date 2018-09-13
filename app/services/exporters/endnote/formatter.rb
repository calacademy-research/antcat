class Exporters::Endnote::Formatter
  def self.format references
    references.map do |reference|
      klass =
        case reference
        when ArticleReference then Exporters::Endnote::Formatter::Article
        when BookReference    then Exporters::Endnote::Formatter::Book
        when NestedReference  then Exporters::Endnote::Formatter::Nested
        when UnknownReference then Exporters::Endnote::Formatter::Unknown
        else raise "Don't know what kind of reference this is: #{reference.inspect}"
        end
      klass.new(reference).format
    end.select(&:present?).join("\n") + "\n"
  end
end

class Exporters::Endnote::Formatter::Base
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
      @reference.author_names.each do |author|
        add "A", author.name
      end
    end
end

class Exporters::Endnote::Formatter::Article < Exporters::Endnote::Formatter::Base
  private

    def kind
      'Journal Article'
    end

    def add_contents
      add 'J', @reference.journal.name
      add 'N', @reference.series_volume_issue
      add 'P', @reference.pagination
    end
end

class Exporters::Endnote::Formatter::Book < Exporters::Endnote::Formatter::Base
  private

    def kind
      'Book'
    end

    def add_contents
      add 'C', @reference.publisher.place_name
      add 'I', @reference.publisher.name
      add 'P', @reference.pagination
    end
end

class Exporters::Endnote::Formatter::Unknown < Exporters::Endnote::Formatter::Base
  private

    def kind
      'Generic'
    end

    def add_contents
      add '1', @reference.citation
    end
end

class Exporters::Endnote::Formatter::Nested < Exporters::Endnote::Formatter::Base
  # don't know how to get EndNote to handle nested references
  def format
    ''
  end
end
