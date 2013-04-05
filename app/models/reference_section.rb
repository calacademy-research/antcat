# coding: UTF-8
class ReferenceSection < ActiveRecord::Base
  belongs_to :taxon

  acts_as_list scope: :taxon

  has_paper_trail

end
