module DatabaseScripts
  class NominaNudaWithChildrenThatAreNotNominaNuda < DatabaseScript
    def results
      genera = Genus.where(nomen_nudum: true).joins(:species).where(species_taxa: { nomen_nudum: false })
      species = Species.where(nomen_nudum: true).joins(:subspecies).where(subspecies_taxa: { nomen_nudum: false })

      Taxon.where(id: genera.select(:id)).or(Taxon.where(id: species.select(:id)))
    end

    def render
      as_table do |t|
        t.header :taxon, :status
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: <i>Nomina nuda</i> with children that are not <i>nomina nuda</i>
category: Catalog
tags: [new!]

issue_description: This *nomen nudum* has children that are not *nomina nuda*.

description: >
