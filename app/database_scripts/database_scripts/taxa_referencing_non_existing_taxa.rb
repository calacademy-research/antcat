module DatabaseScripts
  class TaxaReferencingNonExistingTaxa < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Taxon.where.not(species_id: Taxon.select(:id))
    end

    def render
      as_table do |t|
        t.header :non_existing_species_id, :taxon, :status, :search_history?, :any_history_items?, :any_what_links_here?

        t.rows do |taxon|
          [
            taxon.species_id,
            markdown_taxon_link(taxon),
            taxon.status,
            search_history_link(taxon.species_id),
            (taxon.history_items.any? ? 'Yes' : '-'),
            ('Yes: ' + what_links_here_link(taxon) if taxon.what_links_here(predicate: true))
          ]
        end
      end
    end

    private

      def search_history_link id
        link_to "Search history", versions_path(item_id: id), class: "btn-normal btn-tiny"
      end

      def what_links_here_link taxon
        link_to("What Links Here", taxon_what_links_here_path(taxon), class: "btn-normal btn-tiny")
      end
  end
end

__END__
description: >
  The columns included in this check are: `species_id` (other are OK).

topic_areas: [catalog]
tags: [high-priority]
issue_description: This subspecies belongs to a species that has been deleted, or does not exists for any other reason.
