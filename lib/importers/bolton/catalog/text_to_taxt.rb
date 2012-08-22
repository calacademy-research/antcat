module Importers::Bolton::Catalog::TextToTaxt

  def self.convert texts
    (texts || []).inject('') do |taxt, item|
      taxt << convert_text_to_taxt(item)
    end
  end

  def self.convert_text_to_taxt item
    nested(item) or
    phrase(item)  or
    citation(item)  or
    taxon_name(item)  or
    brackets(item) or
    unparseable(item) or
    delimiter(item) or
    raise "Couldn't convert #{item} to taxt"
  end

  def self.nested item
    return unless item[:text]
    prefix = item.delete :text_prefix
    suffix = item.delete :text_suffix
    delimiter = item[:text].delete :delimiter
    taxt = convert item[:text]
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

  def self.taxon_name item
    keys = [:order_name, :family_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name, :subgenus_epithet, :genus_abbreviation, :subgenus_name, :species_name, :subspecies_name, :species_epithet, :species_group_epithet]
    key, name = find_one_of(keys, item)
    return unless key
    key = key.to_s.gsub(/_name$/, '').to_sym

    taxt = Taxt.encode_taxon_name name, key, item

    authorship = item[:authorship]
    taxt << ' ' << citation(item[:authorship].first) if authorship
    taxt << ': ' << item[:pages] if item[:pages]
    taxt << convert(items[:notes].first) if item[:notes]
    add_delimiter taxt, item
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

  def self.replace_names_with_taxa
    [[Taxon,                [:type_taxt, :headline_notes_taxt, :genus_species_header_note]],
     [ReferenceSection,     [:title, :subtitle, :references]],
     [TaxonomicHistoryItem, [:taxt]],
    ].each do |klass, fields|
      for record in klass.send :all
        for field in fields
          record[field] = replace_names_with_taxa_in_field record[field] if record[field]
        end
        record.save!
      end
    end
  end

  def self.replace_names_with_taxa_in_field taxt
    return unless taxt
    taxt.gsub /{nam (\d+)}/ do |match|
      taxa = Taxon.where(name_id: $1)

      if taxa.blank?
        Progress.error "Couldn't find name #{name}"
        match
      elsif taxa.count > 1
        Progress.error "Found multiple valid targets among #{taxa.map(&:name).map(&:to_s).join(', ')}"
        match
      else
        "{tax #{taxa.first.id}}"
      end
    end
  end

end
