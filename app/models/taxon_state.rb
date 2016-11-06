# TODO default `taxon_states.deleted` to "false" in db.

class TaxonState < ActiveRecord::Base
  include UndoTracker

  belongs_to :taxon

  has_paper_trail
end
