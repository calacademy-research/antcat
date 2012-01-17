module Taxt

  def self.interpolate taxt, user = nil
    return '' unless taxt
    taxt.gsub /{ref (\d+)}/ do |ref|
      ReferenceFormatter.format_interpolation(Reference.find($1), user) rescue ref
    end
  end

  def self.unparseable string
    "{? #{string}}"
  end

  def self.reference reference
    "{ref #{reference.id}}"
  end

  def self.taxon_name data
    fossil_indicator = data[:fossil] ? '&dagger;' : ''

    if data[:family_name] && data[:suborder]
      return "#{fossil_indicator}#{data[:family_name]} (#{data[:suborder]})"
    end

    key = [:order_name, :suborder, :family_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name, :subgenus_name, :species_name, :subspecies_name].find do |key|
      data[key]
    end
    italicize = [:collective_group_name, :genus_name, :subgenus_name, :species_name, :subspecies_name].include? key
    name = data[key]

    output = ''
    output << '<i>' if italicize
    output << fossil_indicator
    output << name
    output << '</i>' if italicize
    output
  end

end
