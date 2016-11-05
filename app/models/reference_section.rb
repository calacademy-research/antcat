class ReferenceSection < ActiveRecord::Base
  include UndoTracker
  include Feed::Trackable

  attr_accessible :taxon_id, :title_taxt, :subtitle_taxt, :references_taxt,:position, :taxon

  belongs_to :taxon

  before_save { |record| CleanNewlines.clean_newlines record, :subtitle_taxt, :references_taxt }

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: :get_current_change_id }
  tracked on: :all, parameters: ->(item) do { taxon_id: item.taxon_id } end
end
