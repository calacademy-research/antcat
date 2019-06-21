module DatabaseScripts
  class SubspeciesWithAnotherSubspeciesAsSpecies < DatabaseScript
    def results
      Subspecies.where(species_id: Subspecies.select(:id))
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :species, :any_history_items?, :any_what_links_here?

        t.rows do |taxon|
          species_record = Subspecies.find_by(id: taxon.species_id)

          [
            markdown_taxon_link(taxon),
            taxon.status,
            species_record.link_to_taxon,
            (taxon.history_items.any? ? 'Yes' : '-'),
            ('Yes: ' + what_links_here_link(taxon) if taxon.what_links_here(predicate: true))
          ]
        end
      end
    end

    private

      def what_links_here_link taxon
        link_to("What Links Here", taxon_what_links_here_path(taxon), class: "btn-normal btn-tiny")
      end
  end
end

__END__
description: >
  More specifically, `Subspecies` records, where the `species_id` is referring to a `Subspecies` record.


  These are not really subspecies, but infrasubspecific taxa, which cannot be represented on AntCat.

topic_areas: [catalog]
tags: [regression-test]
