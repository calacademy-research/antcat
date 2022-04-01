# frozen_string_literal: true

class Subtribe < FamilyGroupTaxon
  VALID_ENDINGS_REGEX = /(ina|iti)\z/

  belongs_to :tribe

  validates(*(TAXA_COLUMNS - [:tribe_id]), absence: true)

  # TMPCLEANUP: Added here for now while refactoring and cleaning up data. Not sure where it really belongs.
  # NOTE: This method is more like "not_invalid_subtribe_name?", since validations already
  # present in `Name` (like valid characters) are not repeated here.
  def self.valid_subtribe_name? name_string
    return false unless name_string.split.size == 1
    name_string.match?(VALID_ENDINGS_REGEX)
  end

  def parent
    tribe
  end

  def parent= _parent_taxon
    raise "cannot update parent of subtribes"
  end

  def update_parent _new_parent
    raise "cannot update parent of subtribes"
  end

  def immediate_children
    Taxon.none
  end
end
