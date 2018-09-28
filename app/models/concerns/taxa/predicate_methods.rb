module Taxa::PredicateMethods
  extend ActiveSupport::Concern

  (Status::STATUSES - [Status::VALID]).each do |status|
    define_method "#{status.downcase.tr(' ', '_')}?" do
      self.status == status
    end
  end

  # Because `#valid?` clashes with ActiveModel.
  def valid_taxon?
    status == Status::VALID
  end

  def invalid?
    status != Status::VALID
  end

  # Overridden in `SpeciesGroupTaxon` (only species and subspecies can be recombinations)
  def recombination?
    false
  end
end
