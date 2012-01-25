# coding: UTF-8
class ReferenceSection < ActiveRecord::Base
  belongs_to :taxon
  acts_as_list :scope => :taxon
end
