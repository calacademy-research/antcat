# coding: UTF-8
class Synonym < ActiveRecord::Base
  belongs_to :junior_synonym, class_name: 'Taxon'; validates :junior_synonym, presence: true
  belongs_to :senior_synonym, class_name: 'Taxon'
end
