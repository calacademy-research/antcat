class Synonym < ApplicationRecord
  include Trackable

  belongs_to :junior_synonym, class_name: 'Taxon'
  belongs_to :senior_synonym, class_name: 'Taxon'

  validates :junior_synonym, :senior_synonym, presence: true
  validate :junior_and_senior_not_same_record

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  trackable parameters: proc {
    { senior_synonym_id: senior_synonym_id, junior_synonym_id: junior_synonym_id }
  }

  private

    def junior_and_senior_not_same_record
      return unless junior_synonym == senior_synonym

      errors.add :base, "junior and senior must refer to different taxa"
      throw :abort
    end
end
