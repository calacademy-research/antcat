# frozen_string_literal: true

module Types
  class ExpandInstitutionAbbreviations
    include Service

    STOP_REGEX = %r{
      (?!               # Negative look-ahead.
        (?:             # Non-capturing.
          [^$\]), .;:/] # Only match abbreviations followed by any of these characters.
        )
      )
    }x

    def initialize content
      @content = content.dup
    end

    def call
      return content if institution_names_by_abbreviation.empty?
      expand_institution_abbreviations!
    end

    private

      attr_reader :content

      def expand_institution_abbreviations!
        content.gsub!(/\b(#{institutions_regex})#{STOP_REGEX}/) do |abbr|
          name = institution_names_by_abbreviation[abbr]
          next abbr unless name

          "<abbr title='#{title_attribute_value(name)}'>#{abbr}</abbr>"
        end

        content
      end

      # Catalog tags are expanded after this step; braces are encoded so they are never expanded in the title.
      def title_attribute_value name
        CGI.escapeHTML(name).gsub(/[{}]/) { |char| "&##{char.ord};" }
      end

      def institution_names_by_abbreviation
        @_institution_names_by_abbreviation ||= Institution.pluck(:abbreviation, :name).to_h
      end

      # `Regexp.union` escapes each abbreviation, so they are matched literally.
      def institutions_regex
        @_institutions_regex ||= Regexp.union(institution_names_by_abbreviation.keys)
      end
  end
end
