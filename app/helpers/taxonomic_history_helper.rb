module TaxonomicHistoryHelper

  def taxonomic_history taxon
    TaxatryFormatter.format_taxonomic_history taxon
  end

end
