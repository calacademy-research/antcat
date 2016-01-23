
module Formatters::AdvancedSearchFormatter
  include ApplicationHelper

  def format taxon
    string = convert_to_text(format_name taxon)
    status = format_status_reference(taxon).html_safe
    string << convert_to_text(' ' + status) if status.present?
    type_localities = format_type_localities(taxon)
    string << convert_to_text(' ' + type_localities) if type_localities.present?
    string << "\n"
    protonym = convert_to_text(format_protonym taxon)
    string << protonym if protonym.present?
    string << "\n\n"
  end

  def format_status_reference taxon
    return format_original_combination_status taxon if taxon.original_combination?
    labels = []
    labels << "#{italicize 'incertae sedis'} in #{Rank[taxon.incertae_sedis_in]}" if taxon.incertae_sedis_in
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
    string << format_name(taxon.current_valid_taxon_including_synonyms)
    string
  end

  def format_protonym taxon
    reference = taxon.protonym.authorship.reference
    string = ''.html_safe
    string << reference.decorate.format
    string << ' ' << document_link(reference.key) if document_link(reference.key)
    string << ' ' << goto_reference_link(reference.key) if goto_reference_link(reference.key)
    string
  end

  def format_type_localities taxon
    string = ''
    if taxon.protonym.locality.present?
      string << add_period_if_necessary(taxon.protonym.locality)
    end
    if taxon.verbatim_type_locality.present?
      string << ' "' + taxon.verbatim_type_locality
      string = add_period_if_necessary string
      string << '"'
    end
    if taxon.type_specimen_repository.present?
      string << ' ' + taxon.type_specimen_repository
      add_period_if_necessary string
    end
    if taxon.type_specimen_code.present?
      string << ' ' + taxon.type_specimen_code
      add_period_if_necessary string
    end
    if taxon.biogeographic_region.present?
      string << ' ' << taxon.biogeographic_region
      string = add_period_if_necessary string
    end
    string
  end

  def format_forms taxon
    return unless taxon.protonym.authorship.forms.present?
    string = 'Forms: '
    string << add_period_if_necessary(taxon.protonym.authorship.forms)
  end

  def document_link reference_key
    reference_key.document_link
  end

  def goto_reference_link reference_key
    reference_key.goto_reference_link
  end

  def senior_synonym_list taxon
    return '' if taxon.senior_synonyms.empty?
    ' of ' << taxon.senior_synonyms.map { |e| format_name(e) }.join(', ')
  end

  def unitalicize string
    raise "Can't unitalicize an unsafe string" unless string.html_safe?
    string = string.dup
    string.gsub!('<i>', '')
    string.gsub!('</i>', '')
    string.html_safe
  end

end
