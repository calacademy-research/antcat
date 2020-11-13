# frozen_string_literal: true

module DatabaseScripts
  class ConvertTaxTagsToProttTagsSeniorSynonymOfOnlyWithIssues < DatabaseScript
    def statistics
    end

    def results
      HistoryItem.where('taxt REGEXP ?', "^Senior synonym of {tax [0-9]+}: {ref [0-9]+}: [0-9]+\.?$")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Taxt', "TT of extracted's protonym", 'Same?'
        t.rows do |history_item|
          extracted_taxon_id = history_item.ids_from_tax_or_taxac_tags.first
          terminal_taxon_id = Protonym.joins(:taxa, :terminal_taxon).
            where(taxa: { id: extracted_taxon_id }).pick('terminal_taxons_protonyms.id')

          same = extracted_taxon_id == terminal_taxon_id
          next if same

          terminal_taxon = Taxon.find(terminal_taxon_id)

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            history_item.taxt,

            taxon_link(terminal_taxon),
            (same ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

title: Convert <code>tax</code> tags to <code>prott</code> tags (senior synonym of, only with issues)


section: convert-tax-to-prott-tags
category: Taxt
tags: [slow]

description: >
  Script column | Description

  --- | ---

  **Extracted taxon** | Taxon in the `tax` tag

  **TT of extracted's protonym** | Terminal taxon of the protonym belonging to **Extracted taxon**

related_scripts:
  - ConvertTaxTagsToProttTagsSeniorSynonymOfOnlyWithIssues
