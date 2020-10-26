# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithUnbalancedParenthesesBracesOrBrackets < DatabaseScript
    LIMIT = 25

    def empty?
      !(
        unbalanced_parentheses.exists? ||
        unbalanced_curly_braces.exists? ||
        unbalanced_square_brackets.exists? ||
        unbalanced_angle_brackets.exists? ||
        unbalanced_double_quotes.exists?
      )
    end

    def unbalanced_parentheses
      HistoryItem.where(<<~SQL.squish).limit(LIMIT)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '(', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, ')', '') )
      SQL
    end

    def unbalanced_curly_braces
      HistoryItem.where(<<~SQL.squish).limit(LIMIT)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '{', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '}', '') )
      SQL
    end

    def unbalanced_square_brackets
      HistoryItem.where(<<~SQL.squish).limit(LIMIT)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, ']', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '[', '') )
      SQL
    end

    def unbalanced_angle_brackets
      HistoryItem.where(<<~SQL.squish).limit(LIMIT)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '>', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '<', '') )
      SQL
    end

    def unbalanced_double_quotes
      HistoryItem.where(<<~SQL.squish).limit(LIMIT)
        (
          CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '"', '') )
        ) % 2 != 0
      SQL
    end

    def render
      render_table(unbalanced_parentheses, "parentheses") +
        render_table(unbalanced_curly_braces, "curly braces") +
        render_table(unbalanced_square_brackets, "square brackets") +
        render_table(unbalanced_angle_brackets, "angle brackets") +
        render_table(unbalanced_double_quotes, "double quotes")
    end

    def render_table table_results, tag_name
      as_table do |t|
        t.caption "Unbalanced #{tag_name}"
        t.header 'History item', 'Taxon', 'taxt'
        t.rows(table_results) do |history_item|
          taxt = history_item.taxt
          taxon = history_item.terminal_taxon

          [
            link_to(history_item.id, history_item_path(history_item)),
            taxon_link(taxon),
            Detax[taxt]
          ]
        end
      end
    end
  end
end

__END__

title: History items with unbalanced parentheses, braces, brackets or double quotes.

section: regression-test
category: Taxt
tags: []

issue_description:

description: >

related_scripts:
  - HistoryItemsWithUnbalancedParenthesesBracesOrBrackets
