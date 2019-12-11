class CreateCombinationPolicy
  attr_reader :errors

  def initialize taxon
    @taxon = taxon
    @errors = []
    validate!
  end

  def allowed?
    errors.empty?
  end

  private

    attr_reader :taxon

    def validate!
      errors << 'taxon is not a species' unless taxon.is_a?(Species)
      errors << 'taxon has soft-validation warnings' if taxon.soft_validation_warnings.present?
      errors << 'taxon has subspecices' if taxon.is_a?(Species) && taxon.subspecies.exists?
      errors << 'taxon has obsolete combinations' if taxon.obsolete_combinations.exists?
      errors << "taxon has 'What Links Here's" if taxon.what_links_here(predicate: true)
      errors << "taxon does not have the status 'valid'" if taxon.invalid?
      errors << 'taxon has junior synonyms' if taxon.junior_synonyms.any?
      errors << "taxon has 'unavailable misspelling's" if any_unavailable_misspellings?
      errors << "taxon has 'unavailable uncategorized's" if any_unavailable_uncategorizeds?
      errors << 'taxon is an unresolved homonym' if taxon.unresolved_homonym?
      errors << 'taxon is a collective group name' if taxon.collective_group_name?
      errors << 'taxon is an ichnotaxon' if taxon.ichnotaxon?
      errors << 'taxon is a nomen nudum' if taxon.nomen_nudum?
      errors << 'taxon has a type taxon' if taxon.type_taxon
    end

    # TODO: Model knowlegde, but we don't want it there (we want to remove it).
    def any_unavailable_misspellings?
      taxon.current_valid_taxon_of.where(status: Status::UNAVAILABLE_MISSPELLING).any?
    end

    # TODO: Model knowlegde, but we don't want it there (we want to remove it).
    def any_unavailable_uncategorizeds?
      taxon.current_valid_taxon_of.where(status: Status::UNAVAILABLE_UNCATEGORIZED).any?
    end
end
