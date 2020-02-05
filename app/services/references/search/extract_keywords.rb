# Accepts a string of keywords (the query) and returns a parsed hash;
# non-matches are placed in `keywords_params[:keywords]`.

module References
  module Search
    class ExtractKeywords
      include Service

      def initialize keyword_string
        @keyword_string = keyword_string
      end

      def call
        keywords_params = {}

        regexes.each do |keyword, regex|
          match = keyword_string.match /#{keyword}: ?#{regex}/i
          next unless match

          # match.names contains named captured groups.
          if match.names.empty?
            # If there are no named captures, use the 'keyword' as key.
            # Eg 'year:2004' --> keywords_params[:year] = '2004'
            keywords_params[keyword.to_sym] = Regexp.last_match(1)
          else
            # If there are named captures, use them as keys.
            # Eg 'year:2004-2005' -->
            #   keywords_params[:start_year] = '2004'
            #   keywords_params[:end_year] = '2005'
            match.names.each { |param| keywords_params[param.to_sym] = match[param] }
          end
          # Replace matched and continue matching.
          keyword_string.gsub! match.to_s, ""
        end

        # This is kind of a hack, but methods further down the line expect :reference_type
        # to contain a symbol (all the other matches, including 'year', are strings).
        if keywords_params[:reference_type].present?
          keywords_params[:reference_type] = keywords_params[:reference_type].to_sym
        end
        # Remove redundant spaces (artifacts from .gsub!)
        keywords_params[:keywords] = keyword_string.squish
        keywords_params
      end

      private

        attr_reader :keyword_string

        # Array of arrays used to compile regexes: [["keyword", "regex_as_string"]].
        #
        # By default, the keyword becomes the key used in `keywords_params`. The regex may
        # contain named groups, which are used when we do not want to use the default key name;
        # this may be necessary in some cases (year must be split in two if the input is a range),
        # or simply if we want to use a different key (`reference_type` is better as key than
        # the ambiguous `type`, but 'type:' is better in the search box).
        #
        # Order matters, because matches are removed from the keyword_string;
        # this makes it easier to match variations of the same keyword without
        # adding too much logic. On the wishlist: a gem to take care of this so that
        # we do not have to re-invent the wheel.
        def regexes
          [
            ["year",   '(?<start_year>\d{4})-(?<end_year>\d{4})'],             # year:2003-2015
            ["year",   '(\d{4})'],                                             # year:2003
            ["type",   '(?<reference_type>nested|unknown|nomissing|missing)'], # type:nested
            ["title",  '"(.*?)"'],                                             # title:"Iceland"
            ["title",  '\'(.*?)\''],                                           # title:'Iceland'
            ["title",  '([^ ]+)'],                                             # title:Iceland
            ["author", '"(.*?)"'],                                             # author:"Barry Bolton"
            ["author", '\'(.*?)\''],                                           # author:'Barry Bolton'
            ["author", '([^ ]+)'],                                             # author:Bolton
            ["doi", '([^ ]+)']                                                 # doi:10.11865/zs.201806
          ]
        end
    end
  end
end
