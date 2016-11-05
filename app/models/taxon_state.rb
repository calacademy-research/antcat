class TaxonState < ActiveRecord::Base
  include UndoTracker

  belongs_to :taxon

  has_paper_trail
end
