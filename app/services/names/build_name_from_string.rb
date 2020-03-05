# Not handled:
# Subtribes: -ina (genera can also end with "ina")
# Names I don't know what they are: Formicariae,  Dorylida

module Names
  RANK_ABBREVIATIONS = [
    'var.',
    'r.',
    'n.',
    'st.',
    'subsp.',
    'subp.',
    'ssp.',
    'f.',
    'm.',
    'morph.',
    'ab.',
    'nat.',
    'f.interm.',
    'v.'
  ]

  class BuildNameFromString
    include Service

    class UnparsableName < StandardError; end

    def initialize name
      @name = name&.squish
    end

    def call
      return Name.new if name.blank?
      name_class.new(name: name)
    end

    private

      attr_reader :name

      def name_class
        return ::SubgenusName if subgenus_name?

        raise UnparsableName, name unless /^[[:alpha:][:blank:]-]+$/.match?(countable_words.join(' '))

        case countable_words.size
        when 1 then single_word_name
        when 2 then ::SpeciesName
        when 3 then ::SubspeciesName
        when 4 then ::InfrasubspeciesName
        else   raise UnparsableName, name
        end
      end

      def words
        @words ||= name.split
      end

      def words_without_subgenus
        @words_without_subgenus ||= words.reject { |word| word =~ /^\(.+?\)$/ }
      end

      def countable_words
        words_without_subgenus.reject { |word| word.in?(RANK_ABBREVIATIONS) }
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
