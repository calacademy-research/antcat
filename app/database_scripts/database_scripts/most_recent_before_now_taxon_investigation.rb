# frozen_string_literal: true

module DatabaseScripts
  class MostRecentBeforeNowTaxonInvestigation < DatabaseScript
    def results
      TypeName.limit(10000)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Protonym taxa', 'Taxon', 'Status', 'now_taxon', 'now_taxon status', 'MRBNT', 'MRBNT status'
        t.rows do |type_name|
          taxon = type_name.taxon

          protonym = type_name.protonym
          protonym_taxa = protonym.taxa

          now_taxon = taxon.now_taxon
          most_recent_before_now_taxon = taxon.most_recent_before_now_taxon

          [
            protonym_link(type_name.protonym),
            taxon_links(protonym_taxa),

            taxon_link(taxon),
            taxon.status,

            (now_taxon == taxon ? '-' : taxon_link(now_taxon)),
            (now_taxon == taxon ? '-' : now_taxon.status),

            (most_recent_before_now_taxon == taxon ? '-' : taxon_link(most_recent_before_now_taxon)),
            (most_recent_before_now_taxon == taxon ? '-' : most_recent_before_now_taxon.status)
          ]
        end
      end
    end
  end
end

__END__

title: <code>most_recent_before_now_taxon</code> investigation

section: research
tags: [taxa, list, slow-render]

issue_description:

description: >
  **Taxon** = set as the `type_names.taxon_id`.

related_scripts:
  - MostRecentBeforeNowTaxonInvestigation
