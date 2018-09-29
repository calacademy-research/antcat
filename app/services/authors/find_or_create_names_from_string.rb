module Authors
  class FindOrCreateNamesFromString
    include Service

    def initialize string
      @string = string
    end

    def call
      import
    end

    private

      attr_reader :string

      # TODO rename.
      def import
        parsed_author_names.map do |name|
          AuthorName.all.where(name: name).find { |possible_name| possible_name.name == name } ||
            AuthorName.create!(name: name, author: Author.create!)
        end
      end

      def parsed_author_names
        Parsers::AuthorParser.parse!(string)
      rescue Citrus::ParseError
        []
      end
  end
end
