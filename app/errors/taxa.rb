module Taxa
  # TODO: Decide what do do with these.
  class TaxonHasSubspecies < StandardError; end
  class TaxonHasInfrasubspecies < StandardError; end

  class TaxonExists < StandardError
    attr_reader :names

    def initialize names
      @names = names
    end
  end

  # TODO: Extract this and all `#update_parent`s into `ForceParentChange`.
  class InvalidParent < StandardError
    attr_reader :taxon, :new_parent

    def initialize taxon, new_parent = nil
      @taxon = taxon
      @new_parent = new_parent
    end

    def message
      "Invalid parent: ##{new_parent&.id} (#{new_parent&.rank}) for ##{taxon.id} (#{taxon.rank})"
    end
  end
end
