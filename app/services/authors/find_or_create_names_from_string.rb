module Authors
  class FindOrCreateNamesFromString
    include Service

    def initialize string
      @string = string
    end

    def call
      import_author_names_string
    end

    private

      attr_reader :string

      # TODO rename.
      def import data
        data.map do |name|
          AuthorName.all.where(name: name).find { |possible_name| possible_name.name == name } ||
            AuthorName.create!(name: name, author: Author.create!)
        end
      end

      def import_author_names_string
        author_data = Parsers::AuthorParser.parse!(string)
        { author_names: import(author_data[:names]), author_names_suffix: author_data[:suffix] }
      rescue Citrus::ParseError
        { author_names: [], author_names_suffix: nil }
      end
  end
end
