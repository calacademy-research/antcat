# frozen_string_literal: true

module FeatureHelpers
  module Selectors
    def selector_for locator
      case locator
      # Edit reference sections.
      when 'the add reference section button'
        "*[data-testid=add-reference-section-button]"
      when 'the edit reference section button'
        "#references-section a.taxt-editor-edit-button"
      when 'the cancel reference section button'
        "#references-section a.taxt-editor-cancel-button"
      when 'the save reference section button'
        '#references-section a.taxt-editor-reference-section-save-button'
      when 'the delete reference section button'
        '#references-section a.taxt-editor-delete-button'

      # Edit history items.
      when 'the add history item button'
        "*[data-testid=add-history-item-button]"
      when 'the edit history item button'
        '#history-items .history-item a.taxt-editor-edit-button'
      when 'the cancel history item button'
        '#history-items .history-item a.taxt-editor-cancel-button'
      when 'the save history item button'
        '#history-items .history-item a.taxt-editor-history-item-save-button'
      when 'the delete history item button'
        '#history-items .history-item a.taxt-editor-delete-button'

      when /"(.+)"/
        Regexp.last_match(1)

      else
        raise %(Can't find mapping from "#{locator}" to a selector)
      end
    end
  end
end
