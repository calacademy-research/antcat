# coding: UTF-8
class Subgenus < Taxon
  belongs_to :genus
  has_many :species, :class_name => 'Species', :order => :name
  validates_presence_of :genus

  def children
    species
  end

  def statistics
  end

end
