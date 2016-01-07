module Taxt
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ApplicationHelper

  # These values are duplicated in taxt_editor.coffee
  REFERENCE_TAG_TYPE = 1
  TAXON_TAG_TYPE = 2
  NAME_TAG_TYPE = 3

  class ReferenceNotFound < StandardError; end

  class TaxonNotFound < StandardError; end

  class NameNotFound < StandardError
    attr_accessor :id

    def initialize message = nil, id = nil
      super(message)
      self.id = id
    end
  end
  
  class IdNotFound < StandardError; end

  ################################
  def self.to_string taxt, user = nil, options = {}
    decode taxt, user, options
  end

  def self.to_display_string taxt, user = nil, options = {}
    options[:display] = true
    to_string taxt, user, options
  end

  def self.to_sentence taxt, user, options = {}
    string = decode taxt, user, options
    add_period_if_necessary string
  end

  def self.to_display_sentence taxt, user, options = {}
    options[:display] = true
    to_sentence taxt, user, options
  end

  ################################
  def self.to_editable taxt
    return '' unless taxt
    taxt = taxt.dup

    if taxt =~ /{ref/
      taxt.gsub! /{ref (\d+)}/ do |ref|
        editable_id = id_for_editable $1, REFERENCE_TAG_TYPE
        to_editable_reference Reference.find($1) rescue "{#{editable_id}}"
      end
    end

    if taxt =~ /{tax/
      taxt.gsub! /{tax (\d+)}/ do |tax|
        editable_id = id_for_editable $1, TAXON_TAG_TYPE
        to_editable_taxon Taxon.find($1) rescue "{#{editable_id}}"
      end
    end

    if taxt =~ /{nam/
      taxt.gsub! /{nam (\d+)}/ do |nam|
        editable_id = id_for_editable $1, NAME_TAG_TYPE
        to_editable_name Name.find($1) rescue "{#{editable_id}}"
      end
    end

    taxt
  end

  def self.to_editable_reference reference
    to_editable_tag reference.id, reference.key.to_s, REFERENCE_TAG_TYPE
  end

  def self.to_editable_taxon taxon
    to_editable_tag taxon.id, taxon.name, TAXON_TAG_TYPE
  end

  def self.to_editable_name name
    to_editable_tag name.id, name.name, NAME_TAG_TYPE
  end

  def self.to_editable_tag id, text, type
    editable_id = id_for_editable id, type
    "{#{text} #{editable_id}}"
  end

  # this value is duplicated in taxt_editor.coffee
  EDITABLE_ID_DIGITS = %{abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}

  def self.from_editable editable_taxt
    editable_taxt.gsub /{((.*?)? )?([#{Regexp.escape EDITABLE_ID_DIGITS}]+)}/ do |string|
      id, type_number = id_from_editable $3
      case type_number
        when REFERENCE_TAG_TYPE
          raise ReferenceNotFound.new(string) unless Reference.find_by_id id
          "{ref #{id}}"
        when TAXON_TAG_TYPE
          raise TaxonNotFound.new(string) unless Taxon.find id
          "{tax #{id}}"
        when NAME_TAG_TYPE
          begin
            Name.find id
          rescue ActiveRecord::RecordNotFound
            raise NameNotFound.new(string, id)
          end
          "{nam #{id}}"
      end
    end
  end

  def self.id_for_editable id, type_number
    AnyBase.base_10_to_base_x(id.to_i * 10 + type_number, EDITABLE_ID_DIGITS).reverse
  end

  # this code is duplicated in taxt_editor.coffee
  def self.id_from_editable editable_id
    number = AnyBase.base_x_to_base_10(editable_id.reverse, EDITABLE_ID_DIGITS)
    id = number / 10
    type_number = number % 10
    return id, type_number
  end

  ################################
  def self.decode taxt, user = nil, options = {}
    return '' unless taxt
    taxt.gsub(/{ref (\d+)}/) do |whole_match|
      decode_reference whole_match, $1, user, options
    end.gsub(/{nam (\d+)}/) do |whole_match|
      decode_name whole_match, $1
    end.gsub(/{tax (\d+)}/) do |whole_match|
      decode_taxon whole_match, $1, options
    end.gsub(/{epi (\w+)}/) do |_|
    end.html_safe
  end

  def self.decode_reference whole_match, reference_id_match, user, options
    if options[:display]
      reference = Reference.find(reference_id_match) rescue whole_match
      reference.decorate.format_inline_citation_without_links rescue whole_match
    else
      reference = Reference.find(reference_id_match) rescue whole_match
      reference.decorate.format_inline_citation options rescue whole_match
    end
  end

  def self.decode_name whole_match, name_id_match
    Name.find(name_id_match).to_html rescue whole_match
  end

  def self.decode_taxon whole_match, taxon_id_match, options
    if options[:display]
      Taxon.find(taxon_id_match).name.to_html
    else
      taxon = Taxon.find taxon_id_match
      if $use_ant_web_formatter # TODO remove dependency on global variable
        link_to_antcat_from_antweb taxon
      else
        link_to_taxon taxon
      end
    end
  rescue
    whole_match
  end

  def self.link_to_antcat_from_antweb taxon #TODO remove
    link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
  end

  def self.link_to_taxon taxon #TODO remove
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  def self.decode_epithet epithet
    italicize epithet
  end

  ################################
  def self.encode_unparseable string
    "{? #{string}}"
  end

  def self.encode_reference reference
    "{ref #{reference.id}}"
  end

  def self.encode_taxon taxon
    "{tax #{taxon.id}}"
  end

  ################################
  def self.replace replace_what, replace_with
    taxt_fields.each do |klass, fields|
      klass.send(:all).each do |record|
        fields.each do |field|
          next unless record[field]
          record[field] = record[field].gsub replace_what, replace_with
        end
        record.save!
      end
    end
  end

  def self.taxt_fields
    [
        [Taxon, [:type_taxt, :headline_notes_taxt, :genus_species_header_notes_taxt]],
        [Citation, [:notes_taxt]],
        [ReferenceSection, [:title_taxt, :subtitle_taxt, :references_taxt]],
        [TaxonHistoryItem, [:taxt]]
    ]
  end

end
