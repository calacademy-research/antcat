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
    taxt.gsub(/{ref (\d+)}/) do |ref|
      Formatters::ReferenceFormatter.format_inline_citation(Reference.find($1), user, options) rescue ref
    end.gsub(/{nam (\d+)}/) do |nam|
      Name.find($1).to_html rescue nam
    end.gsub(/{tax (\d+)}/) do |tax|
      begin
        taxon = Taxon.find $1
        taxon.name.to_html_with_fossil taxon.fossil?
      rescue
        tax
      end
    end.html_safe
  end

  ################################
  def self.encode_unparseable string
    "{? #{string}}"
  end

  def self.encode_reference reference
    "{ref #{reference.id}}"
  end

  def self.encode_taxon_name data
    "{nam #{Name.import(data).id}}"
  rescue
    "{epi #{data[:species_group_epithet]}}"
  end

end
