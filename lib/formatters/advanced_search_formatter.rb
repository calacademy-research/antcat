# coding: UTF-8
module Formatters::AdvancedSearchFormatter
  include ActionView::Helpers::TagHelper

  def format taxon
    string = convert_to_text(format_name taxon)
    status = format_status(taxon).html_safe
    string << convert_to_text(' ' + status) if status.present?
    type_localities = format_type_localities(taxon)
    string << convert_to_text(' ' + type_localities) if type_localities.present?
    string << "\n"
    protonym = convert_to_text(format_protonym taxon, nil)
    string << protonym if protonym.present?
    string << "\n\n"
    string
  end

  def format_status taxon
    return format_original_combination_status taxon if taxon.original_combination?
    labels = []
    labels << "#{italicize 'incertae sedis'} in #{Rank[taxon.incertae_sedis_in].to_s}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{format_name taxon.homonym_replaced_by}"
    elsif taxon.unidentifiable?
      labels << 'unidentifiable'
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.nomen_nudum?
      labels << italicize('nomen nudum')
    elsif taxon.invalid?
      label = Status[taxon].to_s.dup
      label << senior_synonym_list(taxon)
      labels << label
    end
    labels << 'ichnotaxon' if taxon.ichnotaxon?
    labels.join(', ').html_safe
  end

  def format_original_combination_status taxon
    string = 'see '.html_safe
    string << format_name(taxon.current_valid_taxon)
    string
  end

  def format_protonym taxon, user
    reference = taxon.protonym.authorship.reference
    string = ''.html_safe
    string << Formatters::ReferenceFormatter.format(reference)
    string << document_link(reference.key, user)
    string << goto_reference_link(reference.key)
    string << reference_id(reference)
    string
  end

  def format_type_localities taxon
    string = ''
    if taxon.protonym.locality.present?
      string << add_period_if_necessary(taxon.protonym.locality)
    end
    if taxon.verbatim_type_locality.present?
      string << " Verbatim type locality: " + taxon.verbatim_type_locality
      string = add_period_if_necessary string
    end
    if taxon.biogeographic_region.present?
      string << taxon.biogeographic_region
      string = add_period_if_necessary string
    end
    string
  end

  def document_link reference_key, user
    reference_key.document_link user
  end

  def goto_reference_link reference_key
    reference_key.goto_reference_link
  end

  def senior_synonym_list taxon
    return '' unless taxon.senior_synonyms.count > 0
    ' of ' << taxon.senior_synonyms.map {|e| format_name(e)}.join(', ')
  end

  def unitalicize string
    raise "Can't unitalicize an unsafe string" unless string.html_safe?
    string = string.dup
    string.gsub!('<i>', '')
    string.gsub!('</i>', '')
    string.html_safe
  end

end
