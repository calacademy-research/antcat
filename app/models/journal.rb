class Journal < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Trackable

  has_many :references

  validates :name, presence: true, allow_blank: false

  before_destroy :check_not_used

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :all, parameters: proc {
    { name: name, name_was: (name_was if name_changed?) }
  }

  private
    def check_not_used
      if references.present?
        errors.add :base, "cannot delete journal (not unused)"
        return false
      end
    end
end
