module Taxt
  class ReferenceNotFound < StandardError; end

  ################################
  def self.to_string taxt, user = nil, options = {}
    decode taxt, user, options
  end

  def self.to_sentence taxt, user
    string = decode taxt, user
    Formatters::Formatter.add_period_if_necessary string
  end

  def self.to_editable taxt
    return '' unless taxt
    taxt.gsub /{ref (\d+)}/ do |ref|
      editable_id = id_for_editable $1
      to_editable_reference Reference.find($1) rescue "{#{editable_id}}"
    end
  end

  def self.to_editable_reference reference
    editable_id = id_for_editable reference.id
    "{#{reference.key.to_s} #{editable_id}}"
  end

  # this value is duplicated in taxt_editor.coffee
  EDITABLE_ID_DIGITS = %{abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}

  def self.from_editable editable_taxt
    editable_taxt.gsub /{((.*?)? )?([#{Regexp.escape EDITABLE_ID_DIGITS}]+)}/ do |ref|
      id = id_from_editable $3
      raise ReferenceNotFound.new(ref) unless Reference.find_by_id id
      "{ref #{id}}"
    end
  end

  def self.id_for_editable id
    AnyBase.base_10_to_base_x(id.to_i, EDITABLE_ID_DIGITS).reverse
  end

  # this code is duplicated in taxt_editor.coffee
  def self.id_from_editable editable_id
    AnyBase.base_x_to_base_10 editable_id.reverse, EDITABLE_ID_DIGITS
  end

  def self.decode taxt, user = nil, options = {}
    return '' unless taxt
    taxt.gsub(/{ref (\d+)}/) do |whole_match|
      decode_reference whole_match, $1, user, options
    end.gsub(/{nam (\d+)}/) do |whole_match|
      decode_name whole_match, $1
    end.gsub(/{tax (\d+)}/) do |whole_match|
      decode_taxon whole_match, $1, options
    end.gsub(/{epi (\w+)}/) do |_|
      decode_epithet $1
    end.html_safe
  end

  def self.decode_reference whole_match, reference_id_match, user, options
    Formatters::ReferenceFormatter.format_inline_citation(Reference.find(reference_id_match), user, options) rescue whole_match
  end

  def self.decode_name whole_match, name_id_match
    Name.find(name_id_match).to_html rescue whole_match
  end

  def self.decode_taxon whole_match, taxon_id_match, options
    taxon = Taxon.find taxon_id_match
    (options[:formatter] || Formatters::TaxonFormatter).link_to_taxon taxon
  rescue
    whole_match
  end

  def self.decode_epithet epithet
    Formatters::Formatter.italicize epithet
  end

  ################################
  def self.encode_unparseable string
    "{? #{string}}"
  end

  def self.encode_reference reference
    "{ref #{reference.id}}"
  end

  def self.encode_taxon_name data
    epithet = data[:species_group_epithet] || data[:species_epithet]
    if data[:genus_name] or not epithet
      "{nam #{Name.import(data).id}}"
    else
      "{epi #{epithet}}"
    end
  end

end
