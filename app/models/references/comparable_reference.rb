# frozen_string_literal: true

module References
  class ComparableReference
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
      @_title_without_bracketed_phrases ||= remove_bracketed_phrases!(normalized_title.dup)
    end

    def normalized_author
      author_name = principal_author_last_name(reference)
      ActiveSupport::Inflector.transliterate author_name.downcase
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

      def remove_bracketed_phrases! string
        string.gsub!(/\s?\[.*?\]\s?/, ' ')
        string.strip!
        string
      end

      def principal_author_last_name reference
        reference.author_names.first&.last_name
      end
  end
end
