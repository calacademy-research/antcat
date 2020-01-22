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

  def allow_create_obsolete_combination?
    taxon.type.in?(%w[Species]) && taxon.valid_taxon? && taxon.genus.present?
  end

  def allow_force_change_parent?
    taxon.type.in?(%w[Tribe Genus Subgenus Species Subspecies])
  end

  private

    attr_reader :taxon
end
