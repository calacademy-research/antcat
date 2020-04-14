# frozen_string_literal: true

module DatabaseScripts
  class TaxacTagsWithPageNumbers < DatabaseScript
    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "{taxac [0-9]+}: [0-9]")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxt]
          ]
        end
      end
    end
  end
end

__END__

title: <code>taxac</code> tags with page numbers

section: main
category: Taxt
tags: [new!]

description: >
  `taxac` tags should be used for disambiguation purposes only, so no pages should appear after the tag.


  "Taxonomic claims" should include pages -- for these we still use `ref` tags + pages in plaintext.


  **Example**


  * {taxac 429366} junior homonym and junior synonym of {taxac 429365}: {ref 133029}: 451.


  In the above example, "{ref 133029}: 451" is the only litterature citation, while `taxac`
  tags are used instead of `tax` tags for disambiguation purposes.

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
  - TaxacTagsWithPageNumbers
