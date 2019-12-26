module DatabaseScripts
  class TypeTaxaAssignedToMoreThanOneTaxon < DatabaseScript
    def results
      Taxon.where(type_taxon_id: Taxon.group(:type_taxon_id).having('COUNT(id) > 1').select(:type_taxon_id))
    end

    def render
      as_table do |t|
        t.header :rank, :taxon, :status, :protonym, :type_taxon, :tt_protonyms, :unique_tt_protonyms
        t.rows do |taxon|
          protonym_ids_of_siblings = Taxon.where(type_taxon_id: taxon.type_taxon_id).pluck(:protonym_id)

          [
            taxon.type,
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym,
            markdown_taxon_link(taxon.type_taxon),
            protonym_ids_of_siblings.size,
            protonym_ids_of_siblings.uniq.size
          ]
        end
      end
    end
  end
end

__END__

category: Catalog

description: >
  Some of these are OK, maybe all, I'm not sure about the rules.

related_scripts:
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
