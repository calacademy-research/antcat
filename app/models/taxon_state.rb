class TaxonState < ActiveRecord::Base
  include UndoTracker
  has_paper_trail

  belongs_to :taxon
end
