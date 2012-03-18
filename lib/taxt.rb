module Taxt
  class ReferenceNotFound < StandardError; end

  ################################
  def self.to_string taxt, user
    decode taxt, user
  end

  def self.to_editable taxt
    return '' unless taxt
    taxt.gsub /{ref (\d+)}/ do |ref|
      "{#{Reference.find($1).key.to_s} #{id_for_editable $1}}" rescue ref
    end
  end

  def self.from_editable editable_taxt
    editable_taxt.gsub /{((.*?)? )?(\w+)}/ do |ref|
      id = id_from_editable $3
      raise ReferenceNotFound.new(ref) unless Reference.find_by_id id
      "{ref #{id}}"
    end
  end

  def self.id_for_editable id
    id.to_i.to_s 36
  end

  def self.id_from_editable editable_id
    editable_id.to_i 36
  end

  def self.decode taxt, user = nil
    return '' unless taxt
    taxt.gsub /{ref (\d+)}/ do |ref|
      Formatters::ReferenceFormatter.format_inline_citation(Reference.find($1), user) rescue ref
    end.html_safe
  end

  ################################
  def self.encode_unparseable string
    "{? #{string}}"
  end

  def self.encode_reference reference
    "{ref #{reference.id}}"
  end

  def self.encode_taxon_name name, rank, data = {}
    name = name.dup
    if data[:suborder_name]
      return "#{Formatters::CatalogFormatter.fossil(name, data[:fossil])} (#{data[:suborder_name]})"
    end

    if rank == :species_group_epithet
      string = '<i>'.html_safe
      string << Formatters::CatalogFormatter.fossil(name, data[:fossil])
      string << '</i>'.html_safe
      return string
    end

    if data[:genus_abbreviation]
      string = '<i>'.html_safe
      string << Formatters::CatalogFormatter.fossil(data[:genus_abbreviation], data[:fossil])
      if data[:species_epithet]
        string << ' ' << data[:species_epithet]
      elsif data[:subgenus_epithet]
        string << ' (' << data[:subgenus_epithet] << ')'
      else raise
      end
      string << '</i>'.html_safe
      return string
    end

    italicize = [:collective_group, :genus].include? rank

    if rank == :genus && data[:species_epithet]
      if data [:subgenus_epithet]
        name += " (#{data[:subgenus_epithet]})"
      end
      name += ' ' + data[:species_epithet]
    end

    output = ''
    output << '<i>' if italicize
    output << Formatters::CatalogFormatter.fossil(name, data[:fossil])
    output << '?' if data[:questionable]
    output << '</i>' if italicize

    output
  end

end
