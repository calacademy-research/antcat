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
end
