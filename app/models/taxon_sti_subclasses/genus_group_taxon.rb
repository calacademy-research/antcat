# frozen_string_literal: true

# A taxon of genus-group rank (genus or subgenus).
class GenusGroupTaxon < Taxon
  belongs_to :subfamily, optional: true

  # TODO: Probably get rid of all `#immediate_children` and `#immediate_children_rank` in all classes.
  def immediate_children
    species
  end

  def immediate_children_rank
    "species"
  end
end
