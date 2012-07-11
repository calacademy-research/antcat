# coding: UTF-8
class Synonym < ActiveRecord::Base
  belongs_to :junior, class_name: 'Taxon'; validates :junior, presence: true
  belongs_to :senior, class_name: 'Taxon'
end
