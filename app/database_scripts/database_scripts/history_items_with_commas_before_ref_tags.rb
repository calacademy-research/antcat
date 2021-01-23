# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithCommasBeforeRefTags < DatabaseScript
    LIMIT = 500

    # Manually checked in Month Year.
    # Via:
    # DatabaseScripts::HistoryItemsWithCommasBeforeRefTags.new.results.pluck(:id).in_groups_of(10).each { |g| puts g.join(', ') }; nil
    CHECKED_HISTORY_ITEM_IDS = [
      # For the future.
    ]

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.taxts_only.where("taxt REGEXP ?", ", {ref [0-9]+}").
        includes(protonym: :name).limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Highlighted taxt', 'Snippet',
          'Probably ignore', 'Ignore because parsertag', 'Manually checked (Month Year)'
        t.rows do |history_item|
          protonym = history_item.protonym
          taxt = history_item.taxt
          offending_taxt_snippet = taxt[/, \{ref [0-9]+\}/]

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(protonym),
            highlight_taxt(taxt.dup),
            offending_taxt_snippet,

            ('Yes' if probably_ignore?(taxt)),
            ('Yes' if ignore_because_parser_tag?(taxt)),
            ('Yes' if history_item.id.in?(CHECKED_HISTORY_ITEM_IDS))
          ]
        end
      end
    end

    private

      def probably_ignore? taxt
        taxt.match?(/^\[Misspelled as/)
      end

      def ignore_because_parser_tag? taxt
        taxt.match?(/{parsertag comma_before_ref_tag_ok}/)
      end

      def highlight_taxt taxt
        taxt.gsub!(/, \{ref [0-9]+\}/) do |match|
          if probably_ignore? taxt
            bold_notice " here!!! ---&gt; " + match
          else
            bold_warning " here!!! ---&gt; " + match
          end
        end
      end
  end
end

__END__

title: History items with commas before <code>ref</code> tags

section: main
category: Taxt
tags: [new!]

description: >
  We want to use semicolons instead of commas to make items like this parsable by script:


  `Combination in {tax&nbsp;123}: {ref&nbsp;456}: 18, {ref&nbsp;789}: 305.`


  Sorting by the `Highlighted taxt` column is useful for this script, and leaving the disco makes
  is easier to spot the "here!!"s.


  "Misspelled as" items seem to use comma before ref tags a lot - we can ignore
  them for now and decide how to handle them later.


  Complicated items that are false positives can be flagged as OK by adding
  `{ parsertag comma_before_ref_tag_ok}` (without the space after `{`) anywhere in the taxt.

related_scripts:
  - HistoryItemsWithCommasBeforeRefTags
