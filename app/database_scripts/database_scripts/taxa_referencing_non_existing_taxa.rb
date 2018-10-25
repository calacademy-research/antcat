module DatabaseScripts
  class TaxaReferencingNonExistingTaxa < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def species_id_results
      Taxon.where('species_id NOT IN (SELECT id FROM taxa)')
    end

    def render
      as_table do |t|
        t.header :non_existing_species_id, :taxon, :status, :search_history?

        t.rows(species_id_results) do |taxon|
          [
            taxon.species_id,
            markdown_taxon_link(taxon),
            taxon.status,
            search_history_link(taxon.species_id)
          ]
        end
      end
    end

    def search_history_link id
      link_to "Search history", versions_path(item_id: id), class: "btn-normal btn-tiny"
    end
  end
end

__END__
description: >
  The columns included in this check are: `species_id` (other are OK).

topic_areas: [catalog]
