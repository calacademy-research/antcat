# frozen_string_literal: true

module DatabaseScripts
  class MigrationOriginTaxa < DatabaseScript
    def results
      Taxon.where(origin: 'migration').includes(protonym: :name, current_valid_taxon: :name)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'AntWiki', 'Rank', 'Status',
          'current_valid_taxon', 'CVT AntWiki', 'Protonym'
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            taxon_link(taxon),
            taxon.decorate.link_to_antwiki,
            taxon.rank,
            taxon.status,
            taxon_link(current_valid_taxon),
            taxon.current_valid_taxon&.decorate&.link_to_antwiki,
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

title: Migration-origin taxa

section: main
category: Catalog
tags: [slow-render]

issue_description:

description: >

related_scripts:
  - HolOriginTaxa
  - MigrationOriginTaxa
  - UnavailableMisspellings
  - UnavailableUncategorizedTaxa
