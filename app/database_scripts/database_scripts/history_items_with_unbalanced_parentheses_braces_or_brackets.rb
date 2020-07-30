# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithUnbalancedParenthesesBracesOrBrackets < DatabaseScript
    def unbalanced_parentheses
      TaxonHistoryItem.where(<<~SQL)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '(', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, ')', '') )
      SQL
    end

    def unbalanced_curly_braces
      TaxonHistoryItem.where(<<~SQL)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '{', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '}', '') )
      SQL
    end

    def unbalanced_square_brackets
      TaxonHistoryItem.where(<<~SQL)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, ']', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '[', '') )
      SQL
    end

    def unbalanced_angle_brackets
      TaxonHistoryItem.where(<<~SQL)
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '>', '') ) !=
        CHAR_LENGTH(taxt) - CHAR_LENGTH( REPLACE ( taxt, '<', '') )
      SQL
    end

    def render
      render_table(unbalanced_parentheses, "parentheses") +
        render_table(unbalanced_curly_braces, "curly braces") +
        render_table(unbalanced_square_brackets, "square brackets") +
        render_table(unbalanced_angle_brackets, "angle brackets")
    end

    def render_table table_results, tag_name
      as_table do |t|
        t.caption "Unbalanced #{tag_name}"
        t.header 'History item', 'Taxon', 'taxt'
        t.rows(table_results) do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            Detax[taxt]
          ]
        end
      end
    end
  end
end

__END__

title: History items with unbalanced parentheses, braces or brackets

section: regression-test
category: Taxt
tags: []

issue_description:

description: >

related_scripts:
  - HistoryItemsWithUnbalancedParenthesesBracesOrBrackets
