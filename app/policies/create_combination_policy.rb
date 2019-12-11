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
      errors << "taxon has unsupported 'What Links Here's" unless what_links_heres_ok?
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

    # TODO: Probably split WLHs into `TAXA_FIELDS_REFERENCING_TAXA` / "taxt references".
    def what_links_heres_ok?
      what_links_here_except_obsolete_combinations.empty?
    end

    # TODO: Reaching into `table_ref` like this is meh, but let's keep it until we know more.
    def what_links_here_except_obsolete_combinations
      taxon.what_links_here.reject do |table_ref|
        table_ref.table == 'taxa' &&
          table_ref.field == :current_valid_taxon_id &&
          table_ref.id.in?(obsolete_combinations_ids)
      end
    end

    def obsolete_combinations_ids
      @obsolete_combinations_ids ||= taxon.obsolete_combinations.pluck(:id)
    end
end
