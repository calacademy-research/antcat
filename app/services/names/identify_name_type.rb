# frozen_string_literal: true

# Not handled:
#   Subtribes: -ina endings (genera can also end with "-ina")
#   Non-modern names: Formicariae, Dorylida

module Names
  class IdentifyNameType
    include Service

    def initialize name
      @name = name&.squish
    end

    def call
      return if name.blank?
      name_class
    end

    private

      attr_reader :name

      def name_class
        return ::SubgenusName if subgenus_name?

        return unless /^[[:alpha:][:blank:]-]+$/.match?(countable_words.join(' '))

        case countable_words.size
        when 1 then single_word_name
        when 2 then ::SpeciesName
        when 3 then ::SubspeciesName
        when 4 then ::InfrasubspeciesName
        end
      end

      def words
        @_words ||= name.split
      end

      def words_without_subgenus
        @_words_without_subgenus ||= words.reject { |word| word =~ /^\(.+?\)$/ }
      end

      def countable_words
        words_without_subgenus.reject { |word| word.in?(Name::RANK_ABBREVIATIONS) }
      end

      def subgenus_name?
        words.size == 2 && words_without_subgenus.size == 1
      end

      def single_word_name
        case name
        when /idae$/ then ::FamilyName    # "idae" has also been used for subfamilies (like Odontomachidae), but it's non-standard.
        when /inae$/ then ::SubfamilyName
        when /ini$/  then ::TribeName
        when /ii$/   then ::TribeName     # Emery and Forel among others used this convention.
        when /iti$/  then ::SubtribeName  # Brown tried to create a new trend.
        else              ::GenusName     # TODO: It could also be a subtribe (and probably other non-modern ranks).
        end
      end
  end
end
