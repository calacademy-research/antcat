# frozen_string_literal: true

module Authors
  class FindOrInitializeNamesFromString
    include Service

    attr_private_initialize :string

    def call
      parsed_author_names.map do |name|
        AuthorName.where(name: name).find { |case_sensitive_name| case_sensitive_name.name == name } ||
          AuthorName.new(name: name, author: Author.new)
      end
    end

    private

      def parsed_author_names
        Parsers::ParseAuthorNames[string]
      end
  end
end
