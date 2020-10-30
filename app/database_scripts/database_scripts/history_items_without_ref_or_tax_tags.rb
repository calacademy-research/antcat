# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithoutRefOrTaxTags < DatabaseScript
    # Manually checked in October 2020.
    # Via:
    # DatabaseScripts::HistoryItemsWithoutRefOrTaxTags.new.results.pluck(:id).in_groups_of(10).each { |g| puts g.join(', ') }; nil
    CHECKED_HISTORY_ITEM_IDS = [
      243651, 243920, 243926, 244014, 244217, 244364, 244384, 244390, 244421, 244439,
      244564, 244786, 244962, 245175, 245341, 245368, 245389, 245390, 245690, 246319,
      246495, 246687, 246704, 247411, 247775, 247877, 248326, 248896, 249137, 249237,
      249531, 249618, 250027, 250061, 250193, 250392, 250547, 250693, 251172, 251398,
      251483, 251958, 251980, 252075, 252237, 252333, 252798, 253789, 254067, 254183,
      254447, 254657, 254706, 254745, 254804, 254828, 254834, 255004, 255094, 255232,
      255252, 255254, 255256, 255308, 255447, 255492, 255493, 255499, 255529, 255586,
      255611, 255646, 255675, 256161, 256622, 256927, 256929, 257034, 257085, 257322,
      257576, 257615, 257972, 258120, 258121, 258122, 258148, 258149, 258176, 258211,
      258232, 258234, 258236, 258237, 258238, 259216, 259257, 259267, 259598, 259851,
      260129, 260323, 260752, 260801, 260850, 260910, 261006, 261013, 261051, 261105,
      261113, 261130, 261192, 261244, 261292, 261306, 261352, 261447, 261478, 261496,
      262098, 262443, 262554, 262586, 263524, 263716, 263788, 264048, 264129, 264467,
      264543, 264695, 264757, 264861, 265328, 265788, 265976, 266161, 266453, 267059,
      267446, 267533, 267677, 267773, 268012, 268140, 268170, 268495, 269000, 269073,
      269606, 269790, 270348, 270366, 270380, 270396, 271406, 271548, 271589, 271649,
      273059, 273205, 273207, 273387, 273532, 273687, 273698, 273757, 274051, 274165,
      274347, 274396, 274581, 274614, 274623, 274624, 274665, 274670, 274671, 274714,
      274720, 274760, 274782, 276014, 276699, 276700, 276701, 277408, 277426, 277437,
      277542, 277567, 277794, 278229, 278515, 279016, 279018, 279142, 279628, 279629,
      279633, 279634, 279635, 279636, 279637, 279638, 279639, 279640, 279641, 279642,
      279643, 279644, 279645, 279646, 279647, 279648, 279649, 279650, 289593, 289612,
      289789, 289795, 289918, 290168, 291215, 291216, 291217, 291385
    ]

    def results
      HistoryItem.where(Taxt::HistoryItemCleanup::NO_REF_OR_TAX_OR_PRO_TAG).
        includes(protonym: :name)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt',
          'Looks like protonym data?', 'Simple known format?', 'Protonym', 'Manually checked (October 2020)'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.terminal_taxon
          protonym = history_item.protonym
          looks_like_it_belongs_to_the_protonym = looks_like_it_belongs_to_the_protonym?(taxt)
          simple_known_format = simple_known_format?(taxt)

          [
            link_to(history_item.id, history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            ('Yes' if looks_like_it_belongs_to_the_protonym),
            ('Yes' if simple_known_format),
            protonym.decorate.link_to_protonym,
            ('Yes' if history_item.id.in?(CHECKED_HISTORY_ITEM_IDS))
          ]
        end
      end
    end

    def simple_known_format? taxt
      taxt.in?(['Unavailable name', '<i>Nomen nudum</i>'])
    end

    def looks_like_it_belongs_to_the_protonym? taxt
      taxt.starts_with?(',') ||
        taxt =~ /[A-Z]{5,}/
    end
  end
end

__END__

title: History items without <code>ref</code> or <code>tax</code> tags

section: research
category: Taxt
tags: []

description: >
  "Looks like protonym data" = item starts with a comma, or contains five or more uppercase letters
