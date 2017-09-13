module Taxa::TaxaReferences
  extend ActiveSupport::Concern

  def what_links_here
    Taxa::WhatLinksHere[self]
  end

  def any_nontaxt_references?
    Taxa::AnyNonTaxtReferences[self]
  end
end
