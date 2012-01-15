module Bolton::Catalog::TextToTaxt

  def self.convert parser_output
    (parser_output || []).inject('') do |taxt, text_item|
      taxt << convert_one_text_to_taxt(text_item)
    end
  end

  def self.convert_one_text_to_taxt text_item
    nested(text_item)  ||
    phrase(text_item)       ||
    citation(text_item)     ||
    taxon_name(text_item)   ||
    bracket(text_item)      ||
    unparseable(text_item)  ||
    raise("Couldn't convert #{text_item} to taxt")
  end

  def self.bracket text_item
    taxt = ''
    if text_item[:opening_bracket]
      taxt << text_item[:opening_bracket]
    elsif text_item[:closing_bracket]
      taxt << text_item[:closing_bracket]
    else
      return
    end
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
    add_delimiter taxt, text_item
  end

  def self.nested text_item
    return unless text_item[:text]
    delimiter = text_item[:text].delete :delimiter
    taxt = convert text_item[:text]
    add_delimiter taxt, text_item
  end

  def self.taxon_name text_item
    if text_item[:family_name] && text_item[:suborder]
      return add_delimiter "#{text_item[:family_name]} (#{text_item[:suborder]})", text_item
    end
    [:order_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name].each do |key|
      next unless text_item[key]
      taxt = Taxt.taxon_name key, text_item[key]
      return add_delimiter taxt, text_item
    end
    nil
  end

  def self.add_delimiter taxt, text_item
    taxt << text_item[:delimiter] if text_item[:delimiter]
    taxt
  end

end
