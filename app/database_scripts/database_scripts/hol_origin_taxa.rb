# frozen_string_literal: true

module DatabaseScripts
  class HolOriginTaxa < DatabaseScript
    def results
      Taxon.where(origin: 'hol').includes(protonym: :name, current_taxon: :name)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'AntWiki', 'Rank', 'Status',
          'current_taxon', 'CT AntWiki', 'Protonym'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.decorate.link_to_antwiki,
            taxon.rank,
            taxon.status,
            taxon_link(current_taxon),
            taxon.current_taxon&.decorate&.link_to_antwiki,
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

title: HOL-origin taxa

section: main
category: Catalog
tags: [slow-render]

issue_description:

description: >

related_scripts:
  - HolOriginTaxa
  - MigrationOriginTaxa
  - UnavailableUncategorizedTaxa
