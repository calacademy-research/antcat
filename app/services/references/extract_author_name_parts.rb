# frozen_string_literal: true

module References
  class ExtractAuthorNameParts
    include Service

    attr_private_initialize :string

    def call
      name_parts
    end

    private

      def name_parts
        parts = {}
        return parts if string.blank?

        matches = string.match /(.*?), (.*)/
        if matches
          parts[:last] = matches[1]
          parts[:first_and_initials] = matches[2]
        else
          parts[:last] = string
        end

        parts
      end
  end
end
