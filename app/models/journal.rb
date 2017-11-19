class Journal < ActiveRecord::Base
  include Trackable

  has_many :references

  validates :name, presence: true, allow_blank: false

  before_destroy :ensure_not_used

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :all, parameters: proc {
    { name: name, name_was: (name_was if name_changed?) }
  }

  private
    def ensure_not_used
      if references.exists?
        errors.add :base, "Cannot delete journal (not unused)."
        false
      end
    end
end
