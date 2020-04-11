# frozen_string_literal: true

module Authors
  class FindOrInitializeNamesFromString
    include Service

    attr_private_initialize :author_names_string

    # NOTE: We are comparing names in Ruby, since MySQL is not case sensitive.
    # `AuthorName.find_by("BINARY name = ?", name)` also works, but I'm not sure how it handles weird characters.
    def call
      parsed_author_names.map do |name|
        AuthorName.where(name: name).find { |case_sensitive_name| case_sensitive_name.name == name } ||
          AuthorName.new(name: name, author: Author.new)
      end
    end

    private

      def parsed_author_names
        Parsers::ParseAuthorNames[author_names_string]
      end
  end
end
