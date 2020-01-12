class TaxonPolicy
  def initialize taxon
    @taxon = taxon
  end

  def show_create_combination_button?
    taxon.type.in?(%w[Species])
  end

  def allow_create_combination?
    CreateCombinationPolicy.new(taxon).allowed?
  end

  def show_create_combination_help_button?
    taxon.type.in?(%w[Species Subspecies])
  end

  def show_create_obsolete_combination_button?
    taxon.type.in?(%w[Species]) && taxon.valid_taxon?
  end

  def allow_force_change_parent?
    taxon.type.in?(%w[Tribe Genus Subgenus Species Subspecies])
  end

  private

    attr_reader :taxon
end
