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
      raise UnparsableName, "name cannot be blank" if name.blank?
      raise UnparsableName, "'#{name}' must start with a capital letter" unless starts_with_upper_case_letter?

      case name_type
      when :family                         then family_name
      when :subfamily                      then subfamily_name
      when :tribe                          then tribe_name
      when :genus                          then genus_name
      when :subgenus                       then subgenus_name
      when :species                        then species_name
      when :subspecies                     then subspecies_name
      else                                 raise UnparsableName, "cannot parse name #{name}"
      end
    end

    private

      attr_reader :name

      def starts_with_upper_case_letter?
        name[0] == name[0].upcase
      end

      def name_type
        return :subgenus if subgenus_name?

        case num_words_without_subgenus
        when 1    then genus_or_tribe_or_subfamily
        when 2    then :species
        when 3..6 then :subspecies
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
        when /idae$/ then :family
        when /inae$/ then :subfamily
        when /ini$/  then :tribe
        else              :genus
        end
      end

      def family_name
        FamilyName.new(
          name:       name
        )
      end

      def subfamily_name
        SubfamilyName.new(
          name:       name
        )
      end

      def tribe_name
        TribeName.new(
          name:       name
        )
      end

      def genus_name
        GenusName.new(
          name:       name
        )
      end

      def subgenus_name
        SubgenusName.new(
          name:       name
        )
      end

      def species_name
        SpeciesName.new(
          name:       name
        )
      end

      def subspecies_name
        SubspeciesName.new(
          name:       name
        )
      end
  end
end
