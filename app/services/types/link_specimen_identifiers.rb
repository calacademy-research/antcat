module Types
  class LinkSpecimenIdentifiers
    include Service

    SPECIMEN_IDENTIFIER_PREFIXES = [
      "CASENT",
      "FOCOL",
      "JTLC-VIAL",
      "LACMENT",
      "USNMENT",
      "USNMNH",
      "USNM",
      "THNHM",
      "WJT",
      "AMNH",
      "ANIC",
      "ANTWEB",
      "JZC",
      "MCZTYPE",
      "MCZ-ENT"
    ]

    STOP_REGEX = %r{
      (?!               # Negative look-ahead.
        (?:             # Non-capturing.
          [^$\]\), .;/] # Only match abbreviations followed by any of these characters.
        )
      )
    }x

    def initialize content
     @content = content
    end

    def call
      link_specimen_identifiers!
    end

    private

      attr :content

      def link_specimen_identifiers!
        SPECIMEN_IDENTIFIER_PREFIXES.each do |prefix|
          content.gsub!(/\b(#{prefix}[A-Za-z0-9-]+)\b/) do |id|
            "<a href='https://www.antweb.org/specimen/#{id}'>#{id}</a>"
          end
        end

        content
      end
  end
end
