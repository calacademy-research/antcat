class AdvancedSearchPresenter
  include ApplicationHelper

  def format_status_reference taxon
    return format_original_combination_status taxon if taxon.original_combination?
    labels = []
    labels << "#{italicize 'incertae sedis'} in #{taxon.incertae_sedis_in}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{format_name taxon.homonym_replaced_by}"
    elsif taxon.unidentifiable?
      labels << 'unidentifiable'
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.nomen_nudum?
      labels << italicize('nomen nudum')
    elsif taxon.invalid?
      label = taxon.status
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

  def format_type_localities taxon
    string = ''
    if taxon.protonym.locality.present?
      string << add_period_if_necessary(taxon.protonym.locality)
    end
    if taxon.biogeographic_region.present?
      string << ' ' << taxon.biogeographic_region
      string = add_period_if_necessary string
    end
    string
  end

  def senior_synonym_list taxon
    return '' if taxon.senior_synonyms.empty?
    ' of ' << taxon.senior_synonyms.map { |e| format_name(e) }.join(', ')
  end
end
