class Journal < ApplicationRecord
  include Trackable

  has_many :references

  validates :name, presence: true, allow_blank: false

  before_destroy :ensure_not_used

  scope :includes_reference_count, -> do
    left_joins(:references).group(:id).
      select("journals.*, COUNT(references.id) AS reference_count")
  end

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :all, parameters: proc {
    { name: name, name_was: (name_before_last_save if saved_change_to_name?) }
  }

  private

    def ensure_not_used
      if references.exists?
        errors.add :base, "Cannot delete journal (not unused)."
        throw :abort
      end
    end
end
