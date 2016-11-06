class Subtribe < Taxon
  def parent= _parent_taxon
    # probably tribe...
    raise NotImplementedError, "currently we have no subtribes"
  end

  def children
    raise NotImplementedError
  end
end
