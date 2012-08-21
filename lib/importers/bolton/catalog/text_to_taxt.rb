module Importers::Bolton::Catalog::TextToTaxt

  def self.import texts, attribute_name, &block
    object = yield
    taxt = convert object, texts
    object.update_attribute attribute_name, taxt
  end

  def self.convert fixee, texts
    (texts || []).inject('') do |taxt, item|
      taxt << convert_text_to_taxt(fixee, item)
    end
  end

  def self.convert_text_to_taxt fixee, item
    nested(fixee, item) or
    phrase(item)  or
    citation(item)  or
    forward_reference_to_taxon_name(fixee, item)  or
    brackets(item) or
    unparseable(item) or
    delimiter(item) or
    raise "Couldn't convert #{item} to taxt"
  end

  def self.nested fixee, item
    return unless item[:text]
    prefix = item.delete :text_prefix
    suffix = item.delete :text_suffix
    delimiter = item[:text].delete :delimiter
    taxt = convert fixee, item[:text]
    add_delimiter taxt, item
    taxt = prefix + taxt if prefix
    taxt = taxt + suffix if suffix
    taxt
  end

  def self.phrase item
    return unless item[:phrase]
    taxt = item[:phrase]
    add_delimiter taxt, item
  end

  def self.citation item
    return unless item[:author_names]
    taxt = ''
    taxt << item[:author_names].join(' & ') << ', in ' if item[:in]
    taxt << Taxt.encode_reference(::Reference.find_by_bolton_key item)
    taxt << ": #{item[:pages]}" if item[:pages]
    taxt << " (#{item[:forms]})" if item[:forms]
    taxt << notes(item[:notes]) if item[:notes]
    add_delimiter taxt, item
  end

  def self.forward_reference_to_taxon_name fixee, item
    keys = [:order_name, :family_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name, :subgenus_epithet, :genus_abbreviation, :subgenus_name, :species_name, :subspecies_name, :species_epithet, :species_group_epithet]
    key, name = find_one_of(keys, item)
    return unless key
    key = key.to_s.gsub(/_name$/, '').to_sym

    taxt = Taxt.encode_taxon_name name, key, item
    taxt = create_forward_references_to_taxon_names fixee, taxt

    authorship = item[:authorship]
    taxt << ' ' << citation(item[:authorship].first) if authorship
    taxt << ': ' << item[:pages] if item[:pages]
    taxt << convert(items[:notes].first) if item[:notes]
    add_delimiter taxt, item
  end

  def self.create_forward_references_to_taxon_names fixee, taxt
    taxt = taxt.gsub /{nam (\d+)}/ do |match|
      name_id = $1
      forward_ref = ForwardRefFromTaxt.create! fixee: fixee, fixee_attribute: 'taxt', name_id: name_id
      "{fwd #{forward_ref.id}}"
    end
  end

  def self.brackets item
    keys = [:opening_bracket, :closing_bracket, :opening_parenthesis, :closing_parenthesis]
    key, value = find_one_of(keys, item)
    return unless key
    add_delimiter value, item
  end

  def self.unparseable item
    return unless item[:unparseable]
    Taxt.encode_unparseable item[:unparseable]
  end

  def self.delimiter item
    item[:delimiter] or return
  end

  def self.notes items
    items.inject('') do |taxt, item|
      bracketed_item = item.find {|i| i[:bracketed]}
      item.delete bracketed_item if bracketed_item
      taxt << ' [' if bracketed_item
      taxt << ' (' unless bracketed_item
      taxt << convert(item)
      taxt << ']' if bracketed_item
      taxt << ')' unless bracketed_item
      taxt
    end
  end

  def self.add_delimiter taxt, item
    taxt << item[:delimiter] if item[:delimiter]
    taxt
  end

  def self.find_one_of keys, item
    key = keys.find {|key| item[key]} or return
    return key, item[key]
  end

end
