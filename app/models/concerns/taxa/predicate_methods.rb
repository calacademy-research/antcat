module Taxa::PredicateMethods
  extend ActiveSupport::Concern

  def synonym?
    status == Status::SYNONYM
  end

  def homonym?
    status == Status::HOMONYM
  end

  # Because `#valid?` clashes with ActiveModel.
  def valid_taxon?
    status == Status::VALID
  end

  def invalid?
    status != Status::VALID
  end

  def collective_group_name?
    status == Status::COLLECTIVE_GROUP_NAME
  end

  def unidentifiable?
    status == Status::UNIDENTIFIABLE
  end

  def unavailable?
    status == Status::UNAVAILABLE
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

  def original_combination?
    status == Status::ORIGINAL_COMBINATION
  end

  # Overridden in `SpeciesGroupTaxon` (only species and subspecies can be recombinations)
  def recombination?
    false
  end
end
