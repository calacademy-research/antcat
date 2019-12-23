module DatabaseScripts
  class NonValidTaxaSetAsTheCurrentValidTaxonOfAnotherTaxon < DatabaseScript
    def results
      taxa_set_as_current_valid_taxon.where.not(status: Status::VALID)
    end

    private

      def taxa_set_as_current_valid_taxon
        taxa_with_a_current_valid = Taxon.where.not(current_valid_taxon_id: nil).select(:current_valid_taxon_id)
        Taxon.where(id: taxa_with_a_current_valid)
      end
  end
end

__END__

title: Non-valid taxa set as the current valid taxon of another taxon
category: Catalog
tags: [list]

description: >
  This is not necessarily incorrect, but the name of the database column is `current_valid_taxon_id`,
  which does refect how it's used. This script was added as a part of investigating %github814.

related_scripts:
  - NonValidTaxaSetAsTheCurrentValidTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentValidTaxonThatIsNotValid
