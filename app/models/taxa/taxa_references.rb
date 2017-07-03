module Taxa::TaxaReferences
  extend ActiveSupport::Concern

  def references
    what_links_here.taxon_references(omit_taxt: false)
  end

  delegate :nontaxt_references, :any_nontaxt_references?, to: :what_links_here

  private
    def what_links_here
      @_what_links_here ||= Taxa::WhatLinksHere.new(self)
    end
end
