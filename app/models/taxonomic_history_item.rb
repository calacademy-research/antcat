# coding: UTF-8
class TaxonomicHistoryItem < ActiveRecord::Base
  belongs_to :taxon
  acts_as_list scope: :taxon
end
