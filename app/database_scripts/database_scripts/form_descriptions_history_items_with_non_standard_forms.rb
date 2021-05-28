# frozen_string_literal: true

module DatabaseScripts
  class FormDescriptionsHistoryItemsWithNonStandardForms < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      regex = "^(#{Regexp.union(Taxt::StandardHistoryItemFormats::FORMS).source})+$"

      HistoryItem.form_descriptions_relitems.
        where.not("text_value REGEXP ?", regex).
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym/TT', 'taxt', 'Forms', 'Comment'
        t.rows do |history_item|
          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link_with_terminal_taxa(history_item.protonym),
            history_item.to_taxt,
            history_item.text_value,
            comment(history_item.text_value)
          ]
        end
      end
    end

    private

      def comment text_value
        case text_value
        when *Taxt::StandardHistoryItemFormats::FORMS_ALT_FORMATS
          'Alt. format'
        when *Taxt::StandardHistoryItemFormats::FORMS_NON_STANDARD
          'Known non-standard'
        else
          'Unknown format'
        end
      end
  end
end

__END__

title: <code>FormDescriptions</code> history items with non-standard forms

section: research
tags: [new!, rel-hist, future]

description: >

related_scripts:
  - FormDescriptionsHistoryItemsWithNonStandardForms
