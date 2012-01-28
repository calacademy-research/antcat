module Taxt

  ################################
  def self.to_string taxt, user
    decode taxt, user
  end

  def self.decode taxt, user = nil
    return '' unless taxt
    taxt.gsub /{ref (\d+)}/ do |ref|
      ReferenceFormatter.format_inline_citation(Reference.find($1), user) rescue ref
    end.html_safe
  end

  ################################
  def self.encode_unparseable string
    "{? #{string}}"
  end

  def self.encode_reference reference
    "{ref #{reference.id}}"
  end

  def self.encode_taxon_name name, rank, data = {}
    name = name.dup
    if data[:suborder_name]
      return "#{CatalogFormatter.fossil(name, data[:fossil])} (#{data[:suborder_name]})"
    end

    if rank == :species_group_epithet
      string = '<i>'.html_safe
      string << CatalogFormatter.fossil(name, data[:fossil])
      string << '</i>'.html_safe
      return string
    end

    if data[:genus_abbreviation] && data[:subgenus_epithet]
      string = '<i>'.html_safe
      string << CatalogFormatter.fossil(data[:genus_abbreviation], data[:fossil])
      string << ' ('
      string << data[:subgenus_epithet]
      string << ')</i>'.html_safe
      return string
    end

    italicize = [:collective_group, :genus].include? rank

    if rank == :genus && data[:species_epithet]
      if data [:subgenus_epithet]
        name += " (#{data[:subgenus_epithet]})"
      end
      name += ' ' + data[:species_epithet]
    end

    output = ''
    output << '<i>' if italicize
    output << CatalogFormatter.fossil(name, data[:fossil])
    output << '?' if data[:questionable]
    output << '</i>' if italicize

    output
  end

end
