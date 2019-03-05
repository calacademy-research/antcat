class Journal < ApplicationRecord
  include Trackable

  has_many :references, dependent: :restrict_with_error

  validates :name, presence: true

  scope :includes_reference_count, -> do
    left_joins(:references).group(:id).
      select("journals.*, COUNT(references.id) AS reference_count")
  end

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :all, parameters: proc {
    { name: name, name_was: (name_before_last_save if saved_change_to_name?) }
  }
end
