module Taxa::PredicateMethods
  extend ActiveSupport::Concern

  def synonym?
    status == Status::SYNONYM
  end

  # TODO not used (since at least December 2016).
  def junior_synonym_of? taxon
    senior_synonyms.include? taxon
  end

  # TODO not used (since at least December 2016).
  def senior_synonym_of? taxon
    junior_synonyms.include? taxon
  end

  def homonym?
    status == Status::HOMONYM
  end

  # TODO not used (since at least December 2016).
  def homonym_replaced_by? taxon
    homonym_replaced_by == taxon
  end

  # TODO not used (since at least December 2016).
  def unavailable?
    status == Status::UNAVAILABLE
  end

  # TODO not used (since at least December 2016).
  def available?
    !unavailable?
  end

  def invalid?
    status != Status::VALID
  end

  # TODO not used (since at least December 2016).
  def excluded_from_formicidae?
    status == Status::EXCLUDED_FROM_FORMICIDAE
  end

  # TODO not used (since at least December 2016).
  def incertae_sedis_in? rank
    incertae_sedis_in == rank
  end

  def collective_group_name?
    status == Status::COLLECTIVE_GROUP_NAME
  end

  def unidentifiable?
    status == Status::UNIDENTIFIABLE
  end

  def obsolete_combination?
    status == Status::OBSOLETE_COMBINATION
  end

  def unavailable_misspelling?
    status == Status::UNAVAILABLE_MISSPELLING
  end

  def unavailable_uncategorized?
    status == Status::UNAVAILABLE_UNCATEGORIZED
  end

  def nonconfirming_synonym?
    status == Status::NONCONFORMING_SYNONYM
  end

  # A status of 'original combination' means that the taxon/name is a placeholder
  # for the original name of the species under the original genus.
  # The `#original_combination?` predicate checks that.
  def original_combination?
    status == Status::ORIGINAL_COMBINATION
  end

  # Overridden in `SpeciesGroupTaxon` (only species and subspecies can be recombinations)
  def recombination?
    false
  end
end
