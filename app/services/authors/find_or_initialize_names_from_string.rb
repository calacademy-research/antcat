module Authors
  class FindOrInitializeNamesFromString
    include Service

    def initialize string
      @string = string
    end

    def call
      parsed_author_names.map do |name|
        AuthorName.where(name: name).find { |case_sensitive_name| case_sensitive_name.name == name } ||
          AuthorName.new(name: name, author: Author.new)
      end
    end

    private

      attr_reader :string

      def parsed_author_names
        Parsers::ParseAuthorNames[string]
      end
  end
end
