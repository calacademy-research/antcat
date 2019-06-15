module Names
  class CreateNameFromString
    include Service

    class UnparsableName < StandardError; end

    def initialize name
      @name = name
    end

    def call
      raise UnparsableName, name if name.blank?

      case name_type
      when :subspecies                   then create_subspecies_name!
      when :subspecies_with_two_epithets then create_subspecies_name_with_two_epithets!
      when :species                      then create_species_name!
      when :subgenus                     then create_subgenus_name!
      when :genus                        then create_genus_name!
      when :tribe                        then create_tribe_name!
      when :subfamily                    then create_subfamily_name!
      else                               raise UnparsableName, name
      end
    end

    private

      attr_reader :name

      def words
        @words ||= name.split
      end

      def name_type
        case words.size
        when 1    then genus_or_tribe_or_subfamily
        when 2    then subgenus_or_species
        when 3    then :subspecies
        when 4, 5 then :subspecies_with_two_epithets
        end
      end

      def genus_or_tribe_or_subfamily
        case name
        when /inae$/ then :subfamily
        when /ini$/  then :tribe
        else              :genus
        end
      end

      def subgenus_or_species
        if contains_parenthesis? then :subgenus else :species end
      end

      def contains_parenthesis?
        words.second =~ /\(.*?\)/
      end

      def create_subspecies_name!
        SubspeciesName.create!(
          name:         name,
          epithet:      words.third,
          epithets:     [words.second, words.third].join(' ')
        )
      end

      def create_subspecies_name_with_two_epithets!
        SubspeciesName.create!(
          name:         name,
          epithet:      words.last,
          epithets:     words[1..-1].join(' ')
        )
      end

      def create_species_name!
        SpeciesName.create!(
          name:         name,
          epithet:      words.second
        )
      end

      def create_subgenus_name!
        epithet = words.second.tr '()', ''
        SubgenusName.create!(
          name:         name,
          epithet:      epithet
        )
      end

      def create_genus_name!
        GenusName.create!(
          name:         name,
          epithet:      name
        )
      end

      def create_tribe_name!
        TribeName.create!(
          name:         name,
          epithet:      name
        )
      end

      def create_subfamily_name!
        SubfamilyName.create!(
          name:         name,
          epithet:      name
        )
      end
  end
end
