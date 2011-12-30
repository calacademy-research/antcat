module Taxt
  def self.unknown_reference string
    "{ref? #{string}}"
  end
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
