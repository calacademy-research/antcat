module Taxa::PredicateMethods
  extend ActiveSupport::Concern

  def synonym?
    status == 'synonym'
  end

  def junior_synonym_of? taxon
    senior_synonyms.include? taxon
  end
  alias synonym_of? junior_synonym_of?

  def senior_synonym_of? taxon
    junior_synonyms.include? taxon
  end

  def homonym?
    status == 'homonym'
  end

  def homonym_replaced_by? taxon
    homonym_replaced_by == taxon
  end

  def unavailable?
    status == 'unavailable'
  end

  def available?
    !unavailable?
  end

  def invalid?
    status != 'valid'
  end

  def excluded_from_formicidae?
    status == 'excluded from Formicidae'
  end

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
  # The original_combination? predicate checks that.
  def original_combination?
    status == 'original combination'
  end

  def recombination?
    false
  end
end
