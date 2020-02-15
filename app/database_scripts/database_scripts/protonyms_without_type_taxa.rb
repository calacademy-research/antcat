module DatabaseScripts
  class ProtonymsWithoutTypeTaxa < DatabaseScript
    def results
      Protonym.left_outer_joins(:taxa).where(taxa: { type: Rank::CAN_HAVE_TYPE_TAXON_TYPES }).group(:id).having('COUNT(taxa.type_taxon_id) = 0')
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :ranks_of_taxa, :statuses_of_taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', ')
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: []

issue_description:

description: >
  Only ranks above species are included.


  Many of these are replacement names. It seems like the type taxon should be inherited from the homonym it replaced.

related_scripts:
  - ProtonymsWithoutTypeTaxa
  - ProtonymsWithTaxaWithMoreThanOneTypeTaxon
