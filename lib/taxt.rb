module Taxt

  ################################
  def self.to_string taxt, user = nil
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

  def self.encode_taxon_name name, rank, fossil = false, data = {}
    if name && data[:suborder_name]
      return "#{CatalogFormatter.fossil(name, fossil)} (#{data[:suborder_name]})"
    end

    italicize = [:collective_group, :genus].include? rank

    output = ''
    output << '<i>' if italicize
    output << CatalogFormatter.fossil(name, fossil)
    output << '</i>' if italicize
    output
  end

end
