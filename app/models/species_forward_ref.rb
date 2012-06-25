# coding: UTF-8
class SpeciesForwardRef < ActiveRecord::Base

  belongs_to :fixee, class_name: 'Taxon'; validates :fixee, presence: true
  validates  :fixee_attribute, presence: true
  belongs_to :genus; validates :genus, presence: true
  validates  :epithet, presence: true 

end
