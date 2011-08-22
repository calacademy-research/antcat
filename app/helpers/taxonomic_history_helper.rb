# coding: UTF-8
module TaxonomicHistoryHelper

  def taxonomic_history taxon
    CatalogFormatter.format_taxonomic_history taxon
  end

end
