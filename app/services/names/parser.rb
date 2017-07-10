# This is only covered indirectly in feature tests. No specs.

# TODO
# Alternative 1: improve
#   * HTML should be generated in callbacks in the subclasses, not manually.
#   * Probably `remove_column :names, :protonym_html`.
#   * Rename and extract into a new class.
# Alternative 2: completely remove
#   * ??????

class Names::Parser
  extend Formatters::ItalicsHelper

  # Irregular flag allows parsing of names that don't conform to naming
  # standards so we can support bad spellings.
  def self.create_name_from_string! string, irregular = false
    words = string.split " "

    name_type = case words.size
                when 1    then :genus_or_tribe_subfamily
                when 2    then :species
                when 3    then :subspecies
                when 4..5 then :subspecies_with_two_epithets
                end

    if name_type == :genus_or_tribe_subfamily
      name_type = case string
                  when /inae$/ then :subfamily
                  when /idae$/ then :subfamily # actually a family suffix
                  when /ini$/  then :tribe
                  else               :genus
                  end
    end

    case name_type
    when :subspecies
      return SubspeciesName.create! name: string,
                                    name_html: italicize(string),
                                    epithet: words.third,
                                    epithet_html: italicize(words.third),
                                    epithets: [words.second, words.third].join(' ')

    when :subspecies_with_two_epithets
      return SubspeciesName.create! name: string,
                                    name_html: italicize(string),
                                    epithet: words.last,
                                    epithet_html: italicize(words.last),
                                    epithets: words[1..-1].join(' ')
    when :species
      return SpeciesName.create! name: string,
                                 name_html: italicize(string),
                                 epithet: words.second,
                                 epithet_html: italicize(words.second)

    # Note: GenusName.find_each {|t| puts "#{t.name_html == t.protonym_html} #{t.name_html} #{t.protonym_html}" }
    # => all true except Aretidris because protonym_html is nil
    when :genus
      return GenusName.create! name: string,
                               name_html: italicize(string),
                               epithet: string,
                               epithet_html: italicize(string)
                               #protonym_html: italicize(string) #is this used?

    when :tribe
      return TribeName.create! name: string,
                               name_html: string,
                               epithet: string,
                               epithet_html: string
                               #protonym_html: string #is this used?

    # Note: SubfamilyName.all.map {|t| t.name == t.protonym_html }.uniq # => true
    when :subfamily
      return SubfamilyName.create! name: string,
                                   name_html: string,
                                   epithet: string,
                                   epithet_html: string
                                   #protonym_html: string #is this used?
    end

    if irregular
      return SpeciesName.create! name: string,
                                 name_html: italicize(string),
                                 epithet: words.second,
                                 epithet_html: italicize(words.second)
    end
    raise "No `Name` subclass wanted the string: #{string}"
  end
end
