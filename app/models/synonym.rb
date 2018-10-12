class Synonym < ApplicationRecord
  include Trackable

  belongs_to :junior_synonym, class_name: 'Taxon'
  belongs_to :senior_synonym, class_name: 'Taxon'

  validates :junior_synonym, presence: true
  validates :senior_synonym, presence: true

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: [:create, :destroy], parameters: proc {
    { senior_synonym_id: senior_synonym_id, junior_synonym_id: junior_synonym_id }
  }
end
