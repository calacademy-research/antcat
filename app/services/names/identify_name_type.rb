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
        @_words_without_subgenus ||= words.grep_v(/^\(.+?\)$/)
      end

      def countable_words
        words_without_subgenus.reject { |word| word.in?(Name::CONNECTING_TERMS) }
      end

      def subgenus_name?
        words.size == 2 && words_without_subgenus.size == 1
      end

      def single_word_name
        case name
        when /idae$/ then ::FamilyName
        when /inae$/ then ::SubfamilyName
        when /ini$/  then ::TribeName
        when /ii$/   then ::TribeName     # Emery and Forel among others used this convention.
        when /iti$/  then ::SubtribeName  # Brown tried to create a new trend.
        else              ::GenusName     # Subtribes (-ina) cannot be distinguished from genera with the same ending.
        end
      end
  end
end
