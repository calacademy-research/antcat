class Synonym < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include Trackable

  belongs_to :junior_synonym, class_name: 'Taxon'
  belongs_to :senior_synonym, class_name: 'Taxon'

  validates :junior_synonym, presence: true
  validates :senior_synonym, presence: true

  scope :auto_generated, -> { where(auto_generated: true) }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  # NOTE no update hook. Much code that updates synonym relationships simply
  # destroys the syononym object and creates a new one. But there's also code that
  # updates existing synonym relationships, so maybe add that here?
  tracked on: [:create, :destroy], parameters: proc {
    { senior_synonym_id: senior_synonym_id, junior_synonym_id: junior_synonym_id }
  }
end
