class Synonym < ApplicationRecord
  include UndoTracker
  include Feed::Trackable

  attr_accessible :senior_synonym, :junior_synonym,:senior_synonym_id, :junior_synonym_id

  belongs_to :junior_synonym, class_name: 'Taxon'
  belongs_to :senior_synonym, class_name: 'Taxon' # in the process of fixing up, an incomplete Synonym can be created

  validates :junior_synonym, presence: true

  scope :auto_generated, -> { where(auto_generated: true) }

  has_paper_trail meta: { change_id: :get_current_change_id }
  # NOTE no update hook. Much code that updates synonym relationships simply
  # destroys the syononym object and creates a new one. But there's also code that
  # updates existing synonym relationships, so maybe add that here?
  tracked on: [:create, :destroy], parameters: ->(synonym) do
    { senior_synonym_id: synonym.senior_synonym_id,
      junior_synonym_id: synonym.junior_synonym_id }
  end
end
