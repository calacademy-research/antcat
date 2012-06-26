# coding: UTF-8
class SpeciesForwardRef < ActiveRecord::Base

  belongs_to :fixee, class_name: 'Taxon'; validates :fixee, presence: true
  validates  :fixee_attribute, presence: true
  belongs_to :genus; validates :genus, presence: true
  validates  :epithet, presence: true 

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    specieses = Species.find_validest_for_epithet_in_genus epithet, genus
    if specieses.empty?
      Progress.error "Couldn't find species '#{epithet}' in genus '#{genus.name}' when fixing up '#{fixee_attribute}' in '#{fixee.name}'"
    elsif specieses.count > 1
      Progress.error "Found multiple valid targets among #{specieses.map(&:name).map(&:to_s).join(', ')}"
    else
      fixee.update_attributes fixee_attribute.to_sym => specieses.first
    end
  end

end
