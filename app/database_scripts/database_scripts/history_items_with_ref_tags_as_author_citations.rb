# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithRefTagsAsAuthorCitations < DatabaseScript
    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "{tax [0-9]+} {ref [0-9]+}").includes(:taxon).limit(150)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Quick fix', 'Check usage'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          usage_string, matches = check_usage taxt

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            (quick_fix_link(history_item) if matches),
            usage_string
          ]
        end
      end
    end

    private

      def check_usage taxt
        matches = true

        ids = taxt.scan(/{tax (?<tax_id>[0-9]+}) {ref (?<ref_id>[0-9]+)}/)

        string = +''
        ids.each do |(tax_id, ref_id)|
          taxon = Taxon.find(tax_id)
          reference = Reference.find(ref_id)

          string << taxon.link_to_taxon
          string << ' '
          string << if taxon.authorship_reference == reference
                      'matches'
                    else
                      matches = false
                      bold_warning('not OK')
                    end
          string << '<br>'
        end
        [string, matches]
      end

      def quick_fix_link history_item
        link_to 'Convert to taxac!', convert_to_taxac_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: History items with <code>ref</code> tags as author citations
category: Taxt
tags: [has-quick-fix, updated!]

description: >
  **Note that "same" in the "Check usage" column just means that the ID for `ref` tag is the same at the
  reference ID of the taxon's protonym -- both may be incorrect.**


  **Experimental**: Use the "Convert to taxac!" button to quickly replace all `tax` + `ref` tag combinations
  for a history item with a `taxac` tag for the taxon. Refresh the page to get rid cleaned items. The link
  is only visible if the tags match, but like mentioned above, they may match but both may be incorrect.


  **Background**


  `ref` tags used to be the only way to disambiguate homonyms in taxt items.


  Now `tax` tags can be expaned to `taxac` tags (tax + author citation)  include the author citation when rendered.


  Taxts like:


  * [Replacement name for {tax 429029} {ref 125820}]


  can be updated to format:


  * [Replacement name for {taxac 429029}]


  The first example may look like an improvement since the reference is linked (I decided to no link them to make
  it easier to tell them apart from `ref` tags), but it's a misuse of `ref` tags, and it means that the data
  points may not agree (manually specified `ref` tag vs. the actual author citation).


  If the `tax` tag is correct, just remove the `ref` tag and change the `tax` tag to a `taxac` tag to include the author citation.
  This can be done even if the `ref` tag is incorrect since `taxac` tags fetched the author citation from the `tax` tag.


  This script includes the first 150 history items where a `tax` tag is followed by a space and a `ref` tag.
  These can be replaced by script, but very many of them points to the wrong taxon record, which we want to fix first.


  See all [here](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%7Btax+%5B0-9%5D%2B%7D+%7Bref+%5B0-9%5D%2B%7D).


related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
