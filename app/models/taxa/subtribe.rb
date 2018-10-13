# NOTE The are 8 `SubtribeName`s in the db, but no `Subtribe`s.

class Subtribe < Taxon
  def parent= _parent_taxon
    raise NotImplementedError, "currently we have no subtribes"
  end

  def update_parent _new_parent
    raise "cannot update parent of subtribes"
  end

  def children
    raise NotImplementedError
  end
end
