module Taxt

  def self.unparseable string
    "{? #{string}}"
  end

  def self.reference reference
    "{ref #{reference.id}}"
  end

  def self.taxon_name name
    name
  end

  def self.interpolate taxt, user = nil
    taxt.gsub /{ref (\d+)}/ do |ref|
      ReferenceFormatter.format_interpolation(Reference.find($1), user) rescue ref
    end
  end

end
