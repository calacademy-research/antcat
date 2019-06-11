module DatabaseScripts
  class SubspeciesWithoutSpecies < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Subspecies.where(species: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :any_history_items?, :any_what_links_here?

        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
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
topic_areas: [catalog]
tags: [very-slow, high-priority]
issue_description: This subspecies has no species.
