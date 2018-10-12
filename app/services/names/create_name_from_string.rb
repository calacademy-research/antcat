# NOTE This is only covered indirectly in feature tests. No specs.
# TODO HTML should be generated in callbacks in the subclasses, not manually.

class Names::CreateNameFromString
  include Service
  include Formatters::ItalicsHelper

  def initialize string
    @string = string
  end

  def call
    case name_type
    when :subspecies                   then create_subspecies_name!
    when :subspecies_with_two_epithets then create_subspecies_name_with_two_epithets!
    when :species                      then create_species_name!
    when :subgenus                     then create_subgenus_name!
    when :genus                        then create_genus_name!
    when :tribe                        then create_tribe_name!
    when :subfamily                    then create_subfamily_name!
    else raise "No `Name` subclass wanted the string: #{string}"
    end
  end

  private

    attr_reader :string

    def words
      @words ||= string.split
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
      case string
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
      SubspeciesName.create! name:         string,
                             name_html:    italicize(string),
                             epithet:      words.third,
                             epithet_html: italicize(words.third),
                             epithets:     [words.second, words.third].join(' ')
    end

    def create_subspecies_name_with_two_epithets!
      SubspeciesName.create! name:         string,
                             name_html:    italicize(string),
                             epithet:      words.last,
                             epithet_html: italicize(words.last),
                             epithets:     words[1..-1].join(' ')
    end

    def create_species_name!
      SpeciesName.create! name:         string,
                          name_html:    italicize(string),
                          epithet:      words.second,
                          epithet_html: italicize(words.second)
    end

    def create_subgenus_name!
      epithet = words.second.tr '()', ''
      SubgenusName.create! name:         string,
                           name_html:    italicize(string),
                           epithet:      epithet,
                           epithet_html: italicize(epithet)
    end

    def create_genus_name!
      GenusName.create! name:         string,
                        name_html:    italicize(string),
                        epithet:      string,
                        epithet_html: italicize(string)
    end

    def create_tribe_name!
      TribeName.create! name:         string,
                        name_html:    string,
                        epithet:      string,
                        epithet_html: string
    end

    def create_subfamily_name!
      SubfamilyName.create! name:         string,
                            name_html:    string,
                            epithet:      string,
                            epithet_html: string
    end
end
