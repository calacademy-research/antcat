module Taxt

  ################################
  def self.to_string taxt, user = nil
    decode taxt, user
  end

  def self.decode taxt, user = nil
    return '' unless taxt
    taxt.gsub /{ref (\d+)}/ do |ref|
      ReferenceFormatter.format_interpolation(Reference.find($1), user) rescue ref
    end
  end

  ################################
  def self.encode_unparseable string
    "{? #{string}}"
  end

  def self.encode_reference reference
    "{ref #{reference.id}}"
  end

  def self.encode_taxon_name data
    fossil_indicator = data[:fossil] ? '&dagger;' : ''

    if data[:family_name] && data[:suborder_name]
      return "#{fossil_indicator}#{data[:family_name]} (#{data[:suborder_name]})"
    end

    key = [:order_name, :suborder_name, :family_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name, :subgenus_name, :species_name, :subspecies_name].find do |key|
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
