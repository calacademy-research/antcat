module Taxa::Delete
  extend ActiveSupport::Concern

  def delete_impact_list
    Taxa::DeleteImpactList[self]
  end

  def delete_taxon_and_children
    Taxa::DeleteTaxonAndChildren[self]
  end
end
