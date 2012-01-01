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
      reference = Reference.find($1) rescue nil
      return ref unless reference
      if reference.kind_of? MissingReference
        reference.citation
      else
        reference.key.to_link user
      end
    end
  end

end
