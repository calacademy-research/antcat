class Subtribe < Taxon
  def parent= parent_taxon
    # probably tribe...
    raise NotImplementedError, "currently we have no subtribes"
  end
end
