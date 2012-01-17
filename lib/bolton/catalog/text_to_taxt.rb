module Bolton::Catalog::TextToTaxt

  def self.convert parser_output
    (parser_output || []).inject('') do |taxt, text_item|
      taxt << convert_one_text_to_taxt(text_item)
    end
  end

  def self.convert_one_text_to_taxt text_item
    nested(text_item)       ||
    phrase(text_item)       ||
    citation(text_item)     ||
    taxon_name(text_item)   ||
    brackets(text_item)     ||
    unparseable(text_item)  ||
    raise("Couldn't convert #{text_item} to taxt")
  end

  def self.brackets text_item
    brackets = [:opening_bracket, :closing_bracket, :opening_parenthesis, :closing_parenthesis]
    bracket = brackets.find {|e| text_item[e]} or return
    taxt = text_item[bracket]
    add_delimiter taxt, text_item
  end

  def self.phrase text_item
    return unless text_item[:phrase]
    taxt = text_item[:phrase]
    add_delimiter taxt, text_item
  end

  def self.unparseable text_item
    return unless text_item[:unparseable]
    Taxt.unparseable text_item[:unparseable]
  end

  def self.citation text_item
    return unless text_item[:author_names]
    taxt = Taxt.reference ::Reference.find_by_bolton_key text_item
    taxt << ": #{text_item[:pages]}" if text_item[:pages]
    taxt << notes(text_item[:notes]) if text_item[:notes]
    add_delimiter taxt, text_item
  end

  def self.notes text_items
    items = text_items.flatten
    taxt = ''
    bracketed_item = items.find {|i| i[:bracketed]}
    items.delete bracketed_item if bracketed_item
    taxt << ' [' if bracketed_item
    taxt << convert(items)
    taxt << ']' if bracketed_item
    taxt
  end

  def self.nested text_item
    return unless text_item[:text]
    delimiter = text_item[:text].delete :delimiter
    taxt = convert text_item[:text]
    add_delimiter taxt, text_item
  end

  def self.taxon_name text_item
    key = [:order_name, :suborder, :family_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name, :subgenus_name, :species_name, :subspecies_name].find do |key|
      text_item[key]
    end
    return unless key
    taxt = Taxt.taxon_name text_item
    add_delimiter taxt, text_item
  end

  def self.add_delimiter taxt, text_item
    taxt << text_item[:delimiter] if text_item[:delimiter]
    taxt
  end

end
