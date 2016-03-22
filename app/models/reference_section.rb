class ReferenceSection < ActiveRecord::Base
  include UndoTracker

  include Feed::Trackable
  tracked on: :all

  belongs_to :taxon
  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: :get_current_change_id }

  attr_accessible :taxon_id, :title_taxt, :subtitle_taxt, :references_taxt,:position, :taxon

  before_save { |record| CleanNewlines::clean_newlines record, :subtitle_taxt, :references_taxt }
end
