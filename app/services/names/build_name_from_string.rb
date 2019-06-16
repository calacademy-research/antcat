# Not handled:
# Subtribes: -ina
# Non-standard names like: Dacetiti (author tried to create a new trend)
# Names I don't know what they are: Formicariae,  Dorylida
# Probably tribes or subtribes: Acanthostichii, Bregmatomyrminii, Dorylii,  Strumigeniti, Thaumatomyrmii
# Very infrasubspecific names:
# ```
# Name.where.not('name LIKE ?', '%(%').where("LENGTH(name) = (LENGTH(REPLACE(name, ' ', '')) + 5)").first.name
#   => "Acromyrmex aspersus st. mesonotalis var. clarus"
#
# Name.where('name LIKE ?', '%(%').where("LENGTH(name) = (LENGTH(REPLACE(name, ' ', '')) + 6)").first.name
#   => "Atta (Acromyrmex) moelleri subsp. panamensis var. angustata"
# ```

module Names
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
        return SubgenusName if subgenus_name?

        case num_words_without_subgenus
        when 1    then genus_or_tribe_or_subfamily
        when 2    then SpeciesName
        when 3..6 then SubspeciesName
        else      raise UnparsableName, "cannot parse name #{name}"
        end
      end

      def num_words
        @num_words ||= name.split.size
      end

      def num_words_without_subgenus
        @num_words_without_subgenus ||= name.gsub(/\(.*?\)/, '').squish.split.size
      end

      def subgenus_name?
        num_words == 2 && num_words_without_subgenus == 1
      end

      # TODO: It could also be subtribe.
      def genus_or_tribe_or_subfamily
        case name
        when /idae$/ then FamilyName
        when /inae$/ then SubfamilyName
        when /ini$/  then TribeName
        else              GenusName
        end
      end
  end
end
