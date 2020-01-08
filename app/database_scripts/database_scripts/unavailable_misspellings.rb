module DatabaseScripts
  class UnavailableMisspellings < DatabaseScript
    def results
      Taxon.where(status: Status::UNAVAILABLE_MISSPELLING)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :any_what_links_here_columns?, :any_what_links_here_taxts?, :any?, :suggested_action, :what_links_here, :children
        t.rows do |taxon|
          wlh_columns = Taxa::WhatLinksHereColumns[taxon, predicate: true]
          wlh_taxts = Taxa::WhatLinksHereTaxts[taxon, predicate: true]
          any_wlhs = wlh_columns || wlh_taxts

          [
            markdown_taxon_link(taxon),
            taxon.status,
            ('Yes' if wlh_columns),
            ('Yes' if wlh_taxts),
            ('Yes' if any_wlhs),
            ('Delete since no WLHs' unless any_wlhs),
            link_to('What Links Here', taxon_what_links_here_path(taxon), class: 'btn-normal btn-tiny'),
            link_to('Children + check WHLs (slow)', taxa_children_path(taxon, check_what_links_heres: 'yes'), class: 'btn-normal btn-tiny')
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!, slow]

description: >
  Rows where "Suggested action" is "Delete since no WLHs" can be deleted by script.

related_scripts:
  - UnavailableMisspellings
  - UnavailableUncategorizedTaxa
