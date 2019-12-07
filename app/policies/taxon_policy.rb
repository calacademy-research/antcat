class TaxonPolicy
  def initialize taxon
    @taxon = taxon
  end

  def show_create_combination_button?
    rank.in?(%w[species])
  end

  def allow_create_combination?
    CreateCombinationPolicy.new(taxon).allowed?
  end

  def show_create_combination_help_button?
    rank.in?(%w[species subspecies])
  end

  def show_create_obsolete_combination_button?
    rank.in?(%w[species]) && taxon.valid_taxon?
  end

  def allow_force_change_parent?
    rank.in?(%w[tribe genus subgenus species subspecies])
  end

  private

    attr_reader :taxon

    delegate :rank, to: :taxon
end
