module Taxa::PredicateMethods
  extend ActiveSupport::Concern

  def synonym?
    status == 'synonym'
  end

  # TODO not used (December 2016).
  def junior_synonym_of? taxon
    senior_synonyms.include? taxon
  end
  alias synonym_of? junior_synonym_of?

  # TODO not used (December 2016).
  def senior_synonym_of? taxon
    junior_synonyms.include? taxon
  end

  def homonym?
    status == 'homonym'
  end

  # TODO not used (December 2016).
  def homonym_replaced_by? taxon
    homonym_replaced_by == taxon
  end

  # TODO not used (December 2016).
  def unavailable?
    status == 'unavailable'
  end

  # TODO not used (December 2016).
  def available?
    !unavailable?
  end

  def invalid?
    status != 'valid'
  end

  # TODO not used (December 2016).
  def excluded_from_formicidae?
    status == 'excluded from Formicidae'
  end

  # TODO not used (December 2016).
  def incertae_sedis_in? rank
    incertae_sedis_in == rank
  end

  def collective_group_name?
    status == 'collective group name'
  end

  def unidentifiable?
    status == 'unidentifiable'
  end

  def obsolete_combination?
    status == 'obsolete combination'
  end

  def unavailable_misspelling?
    status == 'unavailable misspelling'
  end

  def unavailable_uncategorized?
    status == 'unavailable uncategorized'
  end

  def nonconfirming_synonym?
    status == 'nonconforming synonym'
  end

  # A status of 'original combination' means that the taxon/name is a placeholder
  # for the original name of the species under the original genus.
  # The `#original_combination?` predicate checks that.
  def original_combination?
    status == 'original combination'
  end

  # Overridden in `SpeciesGroupTaxon` (only species and subspecies can be recombinations)
  def recombination?
    false
  end
end
