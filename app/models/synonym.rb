class Synonym < ActiveRecord::Base
  include UndoTracker
  include Feed::Trackable

  attr_accessible :senior_synonym, :junior_synonym,:senior_synonym_id, :junior_synonym_id

  belongs_to :junior_synonym, class_name: 'Taxon'
  belongs_to :senior_synonym, class_name: 'Taxon' # in the process of fixing up, an incomplete Synonym can be created

  validates :junior_synonym, presence: true

  has_paper_trail meta: { change_id: :get_current_change_id }
  # NOTE no update hook; I *think* this is how synonyms are used
  # throught out the app. We could just add the activityies from
  # the controller to avoid spamming the feed, but we also want to list
  # synonym relationships created/removed as a result of other events.
  tracked on: [:create, :destroy], parameters: ->(synonym) do
    { senior_synonym_id: synonym.senior_synonym_id,
      junior_synonym_id: synonym.junior_synonym_id }
  end
end
