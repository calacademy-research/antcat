module Taxa::TaxaReferences
  extend ActiveSupport::Concern

  def what_links_here
    Taxa::WhatLinksHere.new(self).call
  end

  def any_nontaxt_references?
    Taxa::AnyNonTaxtReferences.new(self).call
  end
end
