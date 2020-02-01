module DatabaseScripts
  class HomonymsAsTaxTags < DatabaseScript
    def results
      homonym_ids = Taxon.where(status: Status::HOMONYM).limit(50).pluck(:id) # Very not optimized...
      TaxonHistoryItem.where("taxt REGEXP ?", "{tax (#{homonym_ids.join('|')})+}").includes(:taxon)
    end

    def render
      as_table do |t|
        t.header :history_item, :taxon, :status, :taxt
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

title: Homonyms as <code>tax</code> tags
category: Taxt
tags: [slow]

description: >
  Change the `tax` tag to a `taxac` tag to include the author citation when renderend and remove the entry from this script.


  This script is very slow and primitive. It only check the first 50 taxa with the status 'homonym'.
  It does not check senior homonyms or unresolved junior homonyms. If this script is cleared we can update it to the
  next 50 homonyms, and later look into the other types of cases.

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
