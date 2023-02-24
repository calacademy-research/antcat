# frozen_string_literal: true

module FeatureHelpers
  module Selectors
    def selector_for locator
      case locator

      # Navigation.
      when 'the desktop menu'
        "#desktop-only-header"
      when 'the breadcrumbs'
        "#breadcrumbs"

      # Catalog.
      when 'the taxon browser'
        "#taxon-browser"
      when 'the protonym synopsis'
        "*[data-testid=catalog-protonym-name]"

      # Catalog search.
      when 'the catalog search button'
        "*[data-testid=header-catalog-search-button]"
      when 'the search results'
        "table"

      # Reference search.
      when 'the reference search button'
        "*[data-testid=header-reference-search-button]"

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

      # Editor's Panel.
      when 'the left side of the diff'
        all(".callout .diff")[0]
      when 'the right side of the diff'
        all(".callout .diff")[1]

      when /"(.+)"/
        Regexp.last_match(1)

      else
        raise %(Can't find mapping from "#{locator}" to a selector)
      end
    end
  end
end
