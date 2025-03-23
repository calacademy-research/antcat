# frozen_string_literal: true

# Accepts a search query as a string and returns a struct, with unmatch content in `freetext`.

module References
  module Search
    class ExtractKeywords
      include Service

      Extracted = Struct.new(
        :freetext,
        :year,
        :start_year,
        :end_year,
        :reference_type,
        :title,
        :author,
        :doi,
        keyword_init: true
      ) do
        def to_solr
          to_h.compact_blank
        end

        def searching_with_keywords?
          to_h.except(:freetext).compact_blank.present?
        end
      end

      def initialize search_query
        @search_query = search_query.dup
      end

      def call
        extract_keywords
      end

      private

        attr_reader :search_query

        def extract_keywords
          extracted = Extracted.new

          regexes.each do |keyword, regex|
            next unless (match = search_query.match(/#{keyword}:#{regex}/i))

            # `match.names` contains named captured groups.
            if match.names.empty?
              # If there are no named captures, use the 'keyword' as key.
              # Eg 'year:2004' --> extracted[:year] = '2004'
              extracted[keyword.to_sym] = Regexp.last_match(1)
            else
              # If there are named captures, use them as keys.
              # Eg 'year:2004-2005' -->
              #   extracted[:start_year] = '2004'
              #   extracted[:end_year] = '2005'
              match.names.each { |param| extracted[param.to_sym] = match[param] }
            end

            search_query.gsub!(match.to_s, "") # Remove matched and continue matching.
          end

          extracted[:freetext] = search_query.squish # Remove redundant spaces (artifacts from `.gsub!`).
          extracted
        end

        # Array of arrays used to compile regexes: [["keyword", "regex_as_string"]].
        #
        # By default, the keyword becomes the key used in `keywords`. The regex may
        # contain named groups, which are used when we do not want to use the default key name;
        # this may be necessary in some cases (year must be split in two if the input is a range),
        # or simply if we want to use a different key (`reference_type` is better as key than
        # the ambiguous `type`, but 'type:' is better in the search box).
        #
        # Order matters, because matches are removed from the search query.
        def regexes
          [
            ["year",   '(?<start_year>\d{4})-(?<end_year>\d{4})'],             # year:2003-2015
            ["year",   '(\d{4})'],                                             # year:2003
            ["type",   '(?<reference_type>article|book|nested)'],              # type:nested
            ["title",  '"(.*?)"'],                                             # title:"Iceland"
            ["title",  '\'(.*?)\''],                                           # title:'Iceland'
            ["title",  '([^ ]+)'],                                             # title:Iceland
            ["author", '"(.*?)"'],                                             # author:"Barry Bolton"
            ["author", '\'(.*?)\''],                                           # author:'Barry Bolton'
            ["author", '([^ ]+)'],                                             # author:Bolton
            ["doi",    '([^ ]+)']                                              # doi:10.11865/zs.201806
          ]
        end
    end
  end
end
