module RefactorTaxonFactoriesHelpers
  # Mimics `TaxaController#build_new_taxon` to avoid interference from the factories.
  def build_new_taxon rank
    taxon_class = "#{rank}".titlecase.constantize

    taxon = taxon_class.new
    taxon.build_name
    taxon.build_type_name
    taxon.build_protonym
    taxon.protonym.build_name
    taxon.protonym.build_authorship
    taxon
  end
end
