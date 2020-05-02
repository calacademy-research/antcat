# frozen_string_literal: true

class CreateCombinationPolicy
  attr_private_initialize :taxon

  def errors
    lazy_errors.to_a
  end

  def allowed?
    !lazy_errors.find(&:present?)
  end

  private

    def lazy_errors # rubocop:disable Metrics/PerceivedComplexity
      Enumerator.new do |yielder|
        # Common.
        yielder << 'taxon is not a species' unless taxon.is_a?(Species)
        yielder << "taxon does not have the status 'valid'" unless taxon.valid_status?
        yielder << 'taxon has subspecices' if taxon.is_a?(Species) && taxon.subspecies.exists?

        # Uncommon.
        yielder << 'taxon has infrasubspecices' if taxon.is_a?(Species) && taxon.infrasubspecies.exists?
        yielder << 'taxon has infrasubspecices' if taxon.is_a?(Subspecies) && taxon.infrasubspecies.exists?
        yielder << 'taxon has junior synonyms' if taxon.junior_synonyms.any?
        yielder << "taxon has 'unavailable misspelling's" if any_unavailable_misspellings?
        yielder << "taxon has 'unavailable uncategorized's" if any_unavailable_uncategorizeds?
        yielder << 'taxon is an unresolved homonym' if taxon.unresolved_homonym?
        yielder << 'taxon has a type taxon' if taxon.type_taxon
        yielder << 'taxon is a replacement for a homonym' if any_homonym_replaced_bys?
        yielder << "taxon has unsupported 'What Links Here's" unless what_links_heres_ok?
        yielder << 'taxon has soft validation issues' if taxon.soft_validations.failed?

        # Rare.
        yielder << 'taxon is a nomen nudum' if taxon.nomen_nudum?
        yielder << 'taxon is an ichnotaxon' if taxon.ichnotaxon?
        yielder << 'taxon is a collective group name' if taxon.collective_group_name?
      end
    end

    # TODO: Model knowledge, but we don't want it there (we want to remove it).
    def any_unavailable_misspellings?
      taxon.current_valid_taxon_of.where(status: Status::UNAVAILABLE_MISSPELLING).any?
    end

    # TODO: Model knowledge, but we don't want it there (we want to remove it).
    def any_unavailable_uncategorizeds?
      taxon.current_valid_taxon_of.where(status: Status::UNAVAILABLE_UNCATEGORIZED).any?
    end

    # TODO: Model knowledge, but we don't want it there (we don't know what we want).
    def any_homonym_replaced_bys?
      Taxon.where(homonym_replaced_by: taxon).any?
    end

    # TODO: Probably split WLHs into `TAXA_COLUMNS_REFERENCING_TAXA` / "taxt references".
    def what_links_heres_ok?
      what_links_here_except_obsolete_combinations.empty?
    end

    # TODO: Reaching into `table_ref` like this is meh, but let's keep it until we know more.
    def what_links_here_except_obsolete_combinations
      taxon.what_links_here.all.reject do |table_ref|
        table_ref.table == 'taxa' &&
          table_ref.field == :current_valid_taxon_id &&
          table_ref.id.in?(obsolete_combinations_ids)
      end
    end

    def obsolete_combinations_ids
      @_obsolete_combinations_ids ||= taxon.obsolete_combinations.pluck(:id)
    end
end
