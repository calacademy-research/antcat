# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithRefTagsAsAuthorCitations < DatabaseScript
    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "homonym of {tax [0-9]+} {ref [0-9]+}").limit(100).includes(:taxon)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first 100)<br>
        For all matches, see
        <a href='/taxon_history_items?search_type=REGEXP&q=homonym+of+%7Btax+%5B0-9%5D%2B%7D+%7Bref+%5B0-9%5D%2B%7D'>this link</a>
      STR
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Quick fix', 'Converted to taxac', "Check usage"
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          usage_string, matches = check_usage taxt

          converted_to_taxac = QuickAndDirtyFixes::ConvertTaxToTaxacTags[taxt]
          show_quick_fix_link = (converted_to_taxac != taxt) && matches

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt],

            (quick_fix_link(history_item) if show_quick_fix_link),
            (show_quick_fix_link ? Detax[converted_to_taxac] : bold_warning('no changes and/or mismatch - must be updated manually')),

            usage_string
          ]
        end
      end
    end

    private

      def check_usage taxt
        matches = true

        ids = taxt.scan(/\{tax (?<tax_id>[0-9]+\}) \{ref (?<ref_id>[0-9]+)\}/)

        string = +''
        ids.each do |(tax_id, ref_id)|
          taxon = Taxon.find(tax_id)
          reference = Reference.find(ref_id)

          string << CatalogFormatter.link_to_taxon(taxon)
          string << ' '
          string << if taxon.authorship_reference == reference
                      'tax/ref matches'
                    else
                      matches = false
                      bold_warning('tax/ref do not match')
                    end
          string << '<br><br>'
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

section: main
category: Taxt
tags: [has-quick-fix]

description: >
  **Note that "tax/ref matches" in the "Check usage" column just means that the ID for `ref` tag
  is the same as the reference ID of the taxon's protonym -- both may be incorrect.**


  **Experimental**: Use the "Convert to taxac!" button to quickly replace all `tax` + `ref` tag combinations
  for a history item with a `taxac` tag for the taxon. Refresh the page to get rid cleaned items.
  The link is only visible if the tags match, but like mentioned above, they may match but both may be incorrect.
  **Update:** Page numbers are not removed when using the quick-fix button,
  they can be removed with the quick-fix button in %dbscript:TaxacTagsWithPageNumbers


  **Background**


  `ref` tags used to be the only way to disambiguate homonyms in taxt items, and before that
  there was not even `ref` tags, since all content was in plaintext format.


  When the initial import from plaintext data was made many years ago, the code looked
  for scientific names, and if we had a taxon record with the same name in the database,
  the plaintext name was replaced with a `tax` tag. Similarily, the code looked for text that
  looked like referece keys ("Bolton, 1995d"), and if we had such a reference in the database,
  the plaintext reference key was replaced with a `ref` tag corresponding to that reference.


  That worked pretty well in most cases, but for homonym cases the code would not always be able
  to link the correct taxon record. If we only had a single taxon record with a particular that name,
  the code assumed it had found the correct one and replaced it. I don't know if the code checked
  if there were more than one taxon record with this exact name before replacing it, maybe it did,
  but if we only had one such record at the time the import was made, then the code would perform the replacement.
  If a taxon record for the homonym (junior or senior) was added to the catalog after the initial import,
  the code did not revisit already existing history items.


  That's the big picture, based on what I have puzzled together. If the `tax` and `ref` tags disagree,
  I'd guess that it's more likely that the `ref` tag is correct, since identical reference keys were
  disambiguated with letters in the Bolton files.


  **Present day**


  Now `tax` tags can be expaned to `taxac` tags (tax + author citation) to include the author citation when rendered.


  Taxts like:


  * [Replacement name for {tax 429029} {ref 125820}]


  can be updated to this format:


  * [Replacement name for {taxac 429029}]


  The first example may look like an improvement since the reference is linked (I decided to no link them to make
  it easier to tell them apart from `ref` tags), but it's a misuse of `ref` tags, and it means that the data
  points may not agree (manually specified `ref` tag vs. the actual author citation from the taxon's protonym).


  If the `tax` tag is correct, just remove the `ref` tag and change the `tax` tag to a `taxac` tag to include the author citation.
  This can be done even if the `ref` tag is incorrect since `taxac` tags fetches the author citation from the `tax` tag.


  **Example**


  * {taxac 429366} junior homonym and junior synonym of {taxac 429365}: {ref 133029}: 451.


  Think of `taxac` tag as "disambiguation citations" used to make it clear which taxon is referred
  to (so without backing it up with a scientific citation), and think of `ref` tags + pages,
  as "litterature citations" (which is why we want to include the pagination).


  In the above example, "{ref 133029}: 451" is the only litterature citation, while the `taxac`
  tags are used for disambiguation purposes only.


  The first 100 results are included on this pagee. For all matches, see
  [this link](/taxon_history_items?search_type=REGEXP&q=homonym+of+%7Btax+%5B0-9%5D%2B%7D+%7Bref+%5B0-9%5D%2B%7D)

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
  - PointsToReplacedNameAndUsesRefTagAsAuthorCitation
  - PointsToReplacementNameAndUsesRefTagAsAuthorCitation
  - TaxacTagsWithPageNumbers
