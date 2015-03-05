# coding: UTF-8
class TaxonState < ActiveRecord::Base
  include UndoTracker
  has_paper_trail

  attr_accessible :review_state, :created_at, :updated_at

end