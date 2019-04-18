module Authors
  class FindOrCreateNamesFromString
    include Service

    def initialize string
      @string = string
    end

    def call
      parsed_author_names.map do |name|
        AuthorName.where(name: name).find { |case_sensitive_name| case_sensitive_name.name == name } ||
          AuthorName.create!(name: name, author: Author.create!)
      end
    end

    private

      attr_reader :string

      def parsed_author_names
        Parsers::AuthorParser.parse(string)
      rescue Citrus::ParseError
        []
      end
  end
end
