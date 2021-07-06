# frozen_string_literal: true

module DatabaseScripts
  class ConvertTaxTagsToProttTagsSeniorSynonymOf < DatabaseScript
    PER_PAGE = 500

    def paginated_results page:
      @_paginated_results ||= results.paginate(page: page, per_page: PER_PAGE)
    end

    def results
      HistoryItem.taxts_only.
        where('taxt REGEXP ?', "^Senior synonym of {(tax|taxac) [0-9]+}: {#{Taxt::REF_TAG} [0-9]+}: [0-9]+")
    end

    def render results_to_render: results
      as_table do |t|
        t.header 'History item', 'Protonym', 'Taxt', "TT of extracted's protonym", 'Same?', 'OK?'
        t.rows(results_to_render) do |history_item|
          protonym = history_item.protonym
          taxt = history_item.taxt

          extracted_taxon = Taxon.find(history_item.ids_from_taxon_tags.first)
          protonym_of_extracted_taxon = extracted_taxon.protonym
          terminal_taxon = protonym_of_extracted_taxon.terminal_taxon

          same = extracted_taxon == terminal_taxon
          single_tax_tag = history_item.ids_from_taxon_tags.size == 1

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(protonym),
            taxt,

            taxon_link(terminal_taxon),
            (same ? 'Yes' : bold_warning('No')),
            (single_tax_tag ? 'Yes' : bold_warning('No, too many tax tags'))
          ]
        end
      end
    end
  end
end

__END__

title: Convert <code>tax</code> tags to <code>prott</code> tags (senior synonym of)


section: pa-no-action-required
tags: [taxt-hist, synonyms, slow]

description: >
  Script column | Description

  --- | ---

  **Extracted taxon** | Taxon in the `tax` tag

  **TT of extracted's protonym** | Terminal taxon of the protonym belonging to **Extracted taxon**

related_scripts:
  - ConvertTaxTagsToProttTagsJuniorSynonymOf
  - ConvertTaxTagsToProttTagsSeniorSynonymOf
