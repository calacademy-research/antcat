# frozen_string_literal: true

module References
  class ComparableReference
    ROMAN_NUMERALS = [
      ['i',  1], ['ii',  2], ['iii',  3], ['iv', 4], ['v', 5],
      ['vi', 6], ['vii', 7], ['viii', 8], ['ix', 9], ['x', 10]
    ]

    delegate :type, :year, :pagination, :series_volume_issue, to: :reference

    def initialize reference
      @reference = reference
    end

    def normalized_title
      @_normalized_title = begin
        string = reference.title.dup
        remove_parenthesized_taxon_names! string
        string.replace ActiveSupport::Inflector.transliterate string.downcase
        string
      end
    end

    def title_without_bracketed_phrases!
      @_title_without_bracketed_phrases ||= remove_bracketed_phrases(normalized_title)
    end

    def title_with_replaced_roman_numerals!
      @_title_with_replaced_roman_numerals ||= replace_roman_numerals(title_without_bracketed_phrases!)
    end

    def title_with_removed_punctuation
      remove_punctuation(title_with_replaced_roman_numerals!)
    end

    def normalized_author
      author_name = principal_author_last_name(reference)
      ActiveSupport::Inflector.transliterate author_name.downcase
    end

    def normalized_series_volume_issue
      string = reference.series_volume_issue.dup
      string = remove_year_in_parentheses(string)
      string = remove_no(string)
      string = replace_punctuation_with_space(string)
      string
    end

    private

      attr_reader :reference

      def remove_parenthesized_taxon_names! string
        return string unless (match = string.match(/ \(.+?\)/))

        possible_taxon_names = match.to_s.strip.gsub(/[(),:]/, '').split(/[ ]/)
        any_taxon_names = possible_taxon_names.any? do |word|
          ['Formicidae', 'Hymenoptera'].include? word
        end
        string[match.begin(0)..(match.end(0) - 1)] = '' if any_taxon_names
        string
      end

      def remove_bracketed_phrases string
        string.gsub(/\s?\[.*?\]\s?/, ' ').strip
      end

      def replace_roman_numerals string
        string = string.dup
        ROMAN_NUMERALS.each do |roman, arabic|
          string.gsub!(/\b#{roman}\b/, arabic.to_s)
        end
        string
      end

      def remove_punctuation string
        string.gsub(/[^\w\s]/, '')
      end

      def principal_author_last_name reference
        reference.author_names.first&.last_name
      end

      def replace_punctuation_with_space string
        string.gsub(/[[:punct:]]/, ' ').squish
      end

      def remove_year_in_parentheses string
        string.gsub(/\(\d{4}\)$/, '')
      end

      def remove_no string
        string.gsub(/\(No. (\d+)\)$/, '(\1)')
      end
  end
end
