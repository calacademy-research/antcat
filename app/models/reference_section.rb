class ReferenceSection < ActiveRecord::Base
  include Trackable
  include RevisionsCanBeCompared

  attr_accessible :taxon_id, :title_taxt, :subtitle_taxt, :references_taxt,:position, :taxon

  belongs_to :taxon

  before_save { CleanNewlines.clean_newlines self, :subtitle_taxt, :references_taxt }

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :all, parameters: proc { { taxon_id: taxon_id } }
end
