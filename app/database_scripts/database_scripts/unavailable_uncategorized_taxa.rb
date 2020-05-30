# frozen_string_literal: true

module DatabaseScripts
  class UnavailableUncategorizedTaxa < DatabaseScript
    SHOW_WHAT_LINKS_HERE = false

    def results
      Taxon.where(status: Status::UNAVAILABLE_UNCATEGORIZED).includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        if SHOW_WHAT_LINKS_HERE
          t.header 'Taxon', 'Status', 'current_valid_taxon', 'current_valid_taxon status',
            'Any what links here columns?', 'Any What Links here taxts?', 'Any?', 'What Links Here'
        else
          t.header 'Taxon', 'Status', 'current_valid_taxon', 'current_valid_taxon status'
        end

        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(current_valid_taxon),
            current_valid_taxon.status,

            *what_links_here_coumns(taxon)
          ]
        end
      end
    end

    private

      def what_links_here_coumns taxon
        return [] unless SHOW_WHAT_LINKS_HERE

        [
          ('Yes' if taxon.what_links_here.any_columns?),
          ('Yes' if taxon.what_links_here.any_taxts?),
          ('Yes' if taxon.what_links_here.any?),
          link_to('What Links Here', taxon_what_links_here_path(taxon), class: 'btn-normal btn-tiny')
        ]
      end
  end
end

__END__

section: main
category: Catalog
tags: [high-priority]

issue_description: This taxon has the status "unavailable uncategorized".

description: >
  Taxa with the status `unavailable uncategorized`. We want to convert these to other statuses.

related_scripts:
  - HolOriginTaxa
  - MigrationOriginTaxa
  - UnavailableUncategorizedTaxa
