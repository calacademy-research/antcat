# Not handled:
# Subtribes: -ina
# Non-standard names like: Dacetiti (author tried to create a new trend)
# Names I don't know what they are: Formicariae,  Dorylida
# Probably tribes or subtribes: Acanthostichii, Bregmatomyrminii, Dorylii,  Strumigeniti, Thaumatomyrmii

module Names
  RANK_ABBREVIATIONS = [
    'var.',
    'r.',
    'n.',
    'st.',
    'subsp.',
    'f.',
    'm.',
    'morph.',
    'ab.',
    'nat.'
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

        raise UnparsableName, name unless countable_words.join(' ') =~ /^[[:alpha:][:blank:]-]+$/

        case countable_words.size
        when 1 then genus_or_tribe_or_subfamily
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

      # TODO: It could also be subtribe.
      def genus_or_tribe_or_subfamily
        case name
        when /idae$/ then ::FamilyName
        when /inae$/ then ::SubfamilyName
        when /ini$/  then ::TribeName
        else              ::GenusName
        end
      end
  end
end
