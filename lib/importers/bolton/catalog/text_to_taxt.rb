# coding: UTF-8
module Importers::Bolton::Catalog::TextToTaxt

  def self.convert texts, genus_name = nil, species_epithet = nil
    @genus_name, @species_epithet = genus_name, species_epithet
    (texts || []).inject('') do |taxt, item|
      taxt << convert_text_to_taxt(item)
    end
  end

  def self.convert_text_to_taxt item
    nested_item(item) or
    phrase_item(item)  or
    citation_item(item)  or
    taxon_name_item(item)  or
    bracket_item(item) or
    unparseable_item(item) or
    delimiter_item(item) or
    raise "Couldn't convert #{item} to taxt"
  end

  def self.nested_item item
    return unless item[:text]
    prefix = item.delete :text_prefix
    suffix = item.delete :text_suffix
    delimiter_item = item[:text].delete :delimiter_item
    taxt = convert item[:text], @genus_name
    add_delimiter taxt, item
    taxt = prefix + taxt if prefix
    taxt = taxt + suffix if suffix
    taxt
  end

  def self.phrase_item item
    return unless item[:phrase]
    taxt = item[:phrase].dup
    add_delimiter taxt, item
  end

  def self.citation_item item
    return unless item[:author_names]
    taxt = ''
    taxt << item[:author_names].join(' & ') << ', in ' if item[:in]
    taxt << Taxt.encode_reference(::Reference.find_by_bolton_key item)
    taxt << ": #{item[:pages]}" if item[:pages]
    taxt << " (#{item[:forms]})" if item[:forms]
    taxt << notes_item(item[:notes]) if item[:notes]
    add_delimiter taxt, item
  end

  def self.taxon_name_item item
    keys = [:order_name, :family_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name, :subgenus_epithet, :genus_abbreviation, :subgenus_name, :species_name, :subspecies_name, :species_epithet, :species_group_epithet, :subspecies_epithet]
    key, name = find_one_of(keys, item)
    return unless key
    key = key.to_s.gsub(/_name$/, '').to_sym

    name_item = item.dup
    fill_in_genus_if_necessary name_item
    fill_in_species_if_necessary name_item
    taxt = Taxt.encode_taxon_name name_item

    authorship = item[:authorship]
    taxt << ' ' << citation_item(item[:authorship].first) if authorship
    taxt << ': ' << item[:pages] if item[:pages]
    taxt << convert(items[:notes].first, @genus_name) if item[:notes]
    add_delimiter taxt, item
  end

  def self.fill_in_genus_if_necessary item
    if item[:genus_abbreviation]
      item.delete :genus_abbreviation
      item[:genus_name] = @genus_name
    elsif item[:subgenus_epithet] || item[:species_epithet] || item[:species_group_epithet] || item[:subspecies_epithet]
      unless item[:genus] || item[:genus_name]
        item[:genus_name] = @genus_name
      end
    end
  end

  def self.fill_in_species_if_necessary item
    if item[:subspecies_epithet] || item[:subspecies]
      item[:species_epithet] ||= @species_epithet
    end
    if item[:subspecies_epithet]
      item[:subspecies] = [{subspecies_epithet: item[:subspecies_epithet]}]
      item.delete :subspecies_epithet
    end
  end

  def self.bracket_item item
    keys = [:opening_bracket, :closing_bracket, :opening_parenthesis, :closing_parenthesis]
    key, value = find_one_of(keys, item)
    return unless key
    add_delimiter value, item
  end

  def self.unparseable_item item
    return unless item[:unparseable]
    Taxt.encode_unparseable item[:unparseable]
  end

  def self.delimiter_item item
    item[:delimiter] or return
  end

  def self.notes_item items
    items.inject('') do |taxt, item|
      bracketed_item = item.find {|i| i[:bracketed]}
      item.delete bracketed_item if bracketed_item
      taxt << ' [' if bracketed_item
      taxt << ' (' unless bracketed_item
      taxt << convert(item, @genus_name)
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
