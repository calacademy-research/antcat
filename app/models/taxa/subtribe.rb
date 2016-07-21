class Subtribe < Taxon
  def parent= _parent_taxon
    # probably tribe...
    raise NotImplementedError, "currently we have no subtribes"
  end
end
