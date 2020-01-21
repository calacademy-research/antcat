module DatabaseScripts
  class HistoryItemsWithRefTagsAsAuthorCitations < DatabaseScript
    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "{tax [0-9]+} {ref [0-9]+}").includes(:taxon).limit(150)
    end

    def render
      as_table do |t|
        t.header :history_item, :taxon, :status, :taxt, :check_usage
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            check_usage(taxt)
          ]
        end
      end
    end

    private

      def check_usage taxt
        ids = taxt.scan(/{tax (?<tax_id>[0-9]+}) {ref (?<ref_id>[0-9]+)}/)

        string = ''
        ids.each do |(tax_id, ref_id)|
          taxon = Taxon.find(tax_id)
          reference = Reference.find(ref_id)

          string << taxon.link_to_taxon
          string << ' '
          string << if taxon.authorship_reference == reference
                      'OK'
                    else
                      bold_warning('not OK')
                    end
          string << '<br>'
        end
        string
      end
  end
end

__END__

title: History items with <code>ref</code> tags as author citations
category: Taxt
tags: [new!]

description: >
  `ref` tags used to be the only means to to disambiguate homonyms in taxt items.


  Now the `tax` tags can be expaned to `taxac` tags (tax + author citation)  include the author citation when rendered.


  Taxts like:


  * [Replacement name for {tax 429029} {ref 125820}


  can be updated to format:


  * [Replacement name for {taxac 429029}


  just remove the `ref` tag and change the `tax` tag to a `taxac` tag to include the author citation.


  This script includes the first 150 history items where a `tax` tag is followed by a space and a `ref` tag.
  These can be replaced by script, but very many of them points to the wrong taxon record, which we want to fix first.


  See all [here](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%7Btax+%5B0-9%5D%2B%7D+%7Bref+%5B0-9%5D%2B%7D).


related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
