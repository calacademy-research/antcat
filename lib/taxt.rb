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
      Reference.find($1).interpolation user rescue ref
    end
  end

end
