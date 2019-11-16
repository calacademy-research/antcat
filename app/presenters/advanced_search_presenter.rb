class AdvancedSearchPresenter
  include ApplicationHelper

  def format_status_reference taxon
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
    elsif taxon.valid_taxon?
      labels << "valid"
    elsif taxon.invalid?
      label = taxon.status
      label << senior_synonym_list(taxon)
      labels << label
    end
    labels << 'ichnotaxon' if taxon.ichnotaxon?
    labels.join(', ').html_safe
  end

  private

    def senior_synonym_list taxon
      return '' unless taxon.synonym? && taxon.current_valid_taxon
      ' of ' << format_name(taxon.current_valid_taxon)
    end
end
