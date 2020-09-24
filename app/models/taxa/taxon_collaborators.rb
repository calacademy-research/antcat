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
  end
end
