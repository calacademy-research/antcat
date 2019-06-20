module DatabaseScripts
  class SpeciesWithSpeciesIds < DatabaseScript
    def results
      Species.where.not(species_id: nil)
    end

    def render
      as_table do |t|
        t.header :species, :status, :species_id_, :other_species
        t.rows do |taxon|
          other_species = Taxon.find_by(id: taxon.species_id)

          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.species_id,
            (other_species ? other_species.link_to_taxon : 'Non-existing record')
          ]
        end
      end
    end
  end
end

__END__

description: >
  Species with a `species_id` (which are for subspecies records).

tags: [new!]
topic_areas: [catalog]
