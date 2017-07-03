module Taxa::TaxaReferences
  extend ActiveSupport::Concern

  def references
    Taxa::WhatLinksHere.new(self).call
  end

  def any_nontaxt_references?
    Taxa::AnyNonTaxtReferences.new(self).call
  end
end
