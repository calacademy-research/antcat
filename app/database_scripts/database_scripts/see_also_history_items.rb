module DatabaseScripts
  class SeeAlsoHistoryItems < DatabaseScript
    START =          ["taxt REGEXP ?", "^See also: {ref"]
    SINGLE =         ["taxt REGEXP ?", "^See also: {ref [0-9]+}: [0-9]+$"]
    ANY_EXACTS =     ["taxt REGEXP ?", "^See also: ({ref [0-9]+}: [0-9]+;? ?){1,10}$"]
    ANY_EXACTS_ISH = ["taxt REGEXP ?", "^See also:? ?({ref [0-9]+} ?: +[0-9]+.?;? ?){1,10}$"]

    def results
      TaxonHistoryItem.where(SINGLE).includes(:taxon).limit(100)
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

title: "'See also' history items"
category: Taxt2
tags: [new!, list]

description: >
  Issue: %github842


  Showing first 100.


  This script can be ignored for now. It was added for investigating how to normalize 'see also' history items.


  * [All form descriptions](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%5E%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B+%5C%28&)

  * [1 ref](/taxon_history_items?utf8=✓&search_type=REGEXP&q=%5ESee+also%3A+%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B%24)

  * [2 refs](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%5ESee+also%3A+%28%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B%3B%3F+%3F%29%7B2%7D%24&taxon_type=&taxon_status=&per_page=30)
  - `^See also: ({ref [0-9]+}: [0-9]+;? ?){2}$`

  * [3 refs](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%5ESee+also%3A+%28%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B%3B%3F+%3F%29%7B3%7D%24&taxon_type=&taxon_status=&per_page=30)
  - `^See also: ({ref [0-9]+}: [0-9]+;? ?){3}$`

  * [1-10 refs](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%5ESee+also%3A+%28%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B%3B%3F+%3F%29%7B1%2C10%7D%24&taxon_type=&taxon_status=&per_page=30)
  - `^See also: ({ref [0-9]+}: [0-9]+;? ?){1,10}$`


  Probably handle these first:


  * ["Description of queen"](/taxon_history_items?utf8=%E2%9C%93&search_type=&q=Description+of+queen)

  * ["Description of gyne"](/taxon_history_items?utf8=%E2%9C%93&search_type=&q=Description+of+gyne)
