module References
  class ExtractAuthorNameParts
    include Service

    def initialize string
      @string = string
    end

    def call
      name_parts
    end

    private

      attr_reader :string

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
