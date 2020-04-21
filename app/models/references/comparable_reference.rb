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
  end
end
