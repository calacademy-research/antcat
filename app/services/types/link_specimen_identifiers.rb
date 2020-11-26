# frozen_string_literal: true

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
      "THNHM",
      "WJT",
      "AMNH",
      "ANIC",
      "ANTWEB",
      "JZC",
      "MCZTYPE",
      "MCZ-ENT"
    ]
    STOP_REGEX = /[A-Za-z0-9-]+/
    ANTWEB_SPECIMEN_BASE_URL = 'https://www.antweb.org/specimen/'

    def initialize content
      @content = content.dup
    end

    def call
      link_specimen_identifiers
    end

    private

      attr_reader :content

      def link_specimen_identifiers
        SPECIMEN_IDENTIFIER_PREFIXES.each do |prefix|
          content.gsub!(/\b(#{prefix})#{STOP_REGEX}\b/) do |identifier|
            antweb_specimen_link(identifier)
          end
        end

        content
      end

      def antweb_specimen_link identifier
        "<a href='#{ANTWEB_SPECIMEN_BASE_URL}#{identifier}'>#{identifier}</a>"
      end
  end
end
