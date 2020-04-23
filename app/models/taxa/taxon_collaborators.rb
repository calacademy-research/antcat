# frozen_string_literal: true

module Taxa
  class TaxonCollaborators
    attr_private_initialize :taxon

    def policy
      @_policy ||= TaxonPolicy.new(taxon)
    end

    def soft_validations
      @_soft_validations ||= SoftValidations.new(taxon, SoftValidations::TAXA_DATABASE_SCRIPTS_TO_CHECK)
    end

    def what_links_here
      @_what_links_here ||= Taxa::WhatLinksHere.new(taxon)
    end

    def virtual_history_items
      @_virtual_history_items ||= all_virtual_history_items.select(&:publicly_visible?)
    end

    # The reason we have `#virtual_history_items` and `#all_virtual_history_items` is because for as long as
    # data is being migrated to "virtual history items", we want to be able to "preview" items before we actually make
    # them publicly visible in the catalog.
    def all_virtual_history_items
      @_all_virtual_history_items ||= Taxa::VirtualHistoryItemsForTaxon[taxon]
    end
  end
end
