# frozen_string_literal: true

module CucumberHelpers
  module Selectors
    def selector_for locator
      case locator

      # Navigation.
      when 'the page header'
        "#header"
      when 'the desktop menu'
        "#desktop-menu"
      when 'the breadcrumbs'
        "#breadcrumbs"

      # Catalog.
      when 'the taxon browser'
        "#taxon-browser-new"
      when 'the protonym'
        "#taxon-description #protonym-synopsis > span.name"
      when 'the nomen synopsis'
        "div#nomen-synopsis"
      when 'the citations section'
        '#citations'

      # Catalog search.
      when 'the catalog search button'
        "#header-catalog-search-button-test-hook"
      when 'the search results'
        "table"

      # Reference search.
      when 'the reference search button'
        "#header-reference-search-button-test-hook"

      # Edit reference sections.
      when 'the add reference section button'
        "#add-reference-section-button-test-hook"
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
        '#add-history-item-button-test-hook'
      when 'the edit history item button'
        '#history-items .history-item a.taxt-editor-edit-button'
      when 'the cancel history item button'
        '#history-items .history-item a.taxt-editor-cancel-button'
      when 'the save history item button'
        '#history-items .history-item a.taxt-editor-history-item-save-button'
      when 'the delete history item button'
        '#history-items .history-item a.taxt-editor-delete-button'

      # Editor's Panel.
      when 'the activity feed'
        'table.activities'

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

World CucumberHelpers::Selectors
