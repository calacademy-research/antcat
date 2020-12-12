# frozen_string_literal: true

module DatabaseScripts
  class GeneraWithNamesThatAreDifferentFromTheirProtonymsName < DatabaseScript
    def results
      Genus.where.not(status: Status::UNAVAILABLE_MISSPELLING).
        joins(:name, protonym: :name).where('names.name != names_protonyms.name')
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym', 'Protonym taxa'
        t.rows do |taxon|
          protonym = taxon.protonym

          [
            taxon_link(taxon),
            taxon.status,
            protonym_link(protonym),
            taxon_links(protonym.taxa)
          ]
        end
      end
    end
  end
end

__END__

title: Genera with names that are different from their protonyms' name

section: main
category: Catalog
tags: [new!]

issue_description: This genus does not have the same name as its protonym.

description: >
  Excluded statuses: `unavailable misspelling`

related_scripts:
  - GeneraWithNamesThatAreDifferentFromTheirProtonymsName
