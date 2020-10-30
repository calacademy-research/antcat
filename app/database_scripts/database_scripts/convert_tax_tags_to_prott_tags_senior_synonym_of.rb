# frozen_string_literal: true

module DatabaseScripts
  class ConvertTaxTagsToProttTagsSeniorSynonymOf < DatabaseScript
    PER_PAGE = 500

    def paginated_results page:
      @_paginated_results ||= results.paginate(page: page, per_page: PER_PAGE)
    end

    def results
      HistoryItem.where('taxt REGEXP ?', "^Senior synonym of {tax [0-9]+}: {ref [0-9]+}: [0-9]+\.?$")
    end

    def render results_to_render: results
      as_table do |t|
        t.header 'History item', 'Protonym', 'Taxt', 'Extracted taxon', "TT of extracted's protonym", 'Same?'
        t.rows(results_to_render) do |history_item|
          protonym = history_item.protonym
          taxt = history_item.taxt

          extracted_taxon = Taxon.find(history_item.ids_from_tax_or_taxac_tags.first)
          protonym_of_extracted_taxon = extracted_taxon.protonym
          terminal_taxon = protonym_of_extracted_taxon.terminal_taxon

          same = extracted_taxon == terminal_taxon

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(protonym),
            Detax[taxt],

            taxon_link(extracted_taxon),
            taxon_link(terminal_taxon),

            (same ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

title: Convert <code>tax</code> tags to <code>prott</code> tags (senior synonym of)


section: convert-tax-to-prott-tags
category: Taxt
tags: [new!]

description: >
  Script column | Description

  --- | ---

  **Extracted taxon** | Taxon in the `tax` tag

  **TT of extracted's protonym** | Terminal taxon of the protonym belonging to **Extracted taxon**

related_scripts:
  - ConvertTaxTagsToProttTagsSeniorSynonymOf
