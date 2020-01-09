# To avoid `/app/helpers` and for things that do not belong in the main model.

class EditorTaxonViewObject
  def initialize taxon
    @taxon = taxon
  end

  def taxa_with_same_name
    @taxa_with_same_name ||= Taxon.where(name_cache: taxon.name_cache).where.not(id: taxon.id)
  end

  private

    attr_reader :taxon
end
