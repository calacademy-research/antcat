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

  def self.taxon_name type, name, fossil = false
    italicize = type == :collective_group_name || type == :genus_name
    output = ''
    output << '<i>' if italicize
    output << '&dagger;' if fossil
    output << name
    output << '</i>' if italicize
    output
  end

end
