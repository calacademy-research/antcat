# coding: UTF-8
class SpeciesGroupForwardRef < ActiveRecord::Base
  belongs_to :fixee, polymorphic: true; validates :fixee, presence: true
  validates  :fixee_attribute, presence: true
  belongs_to :genus; validates :genus, presence: true
  validates  :epithet, presence: true 

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    specieses = SpeciesGroupTaxon.find_validest_for_epithet_in_genus epithet, genus
    if specieses.blank?
      Progress.error "Couldn't find species '#{epithet}' in genus '#{genus.name}' when fixing up '#{fixee_attribute}' in '#{fixee}'"
    elsif specieses.count > 1
      Progress.error "Found multiple valid targets among #{specieses.map(&:name).map(&:to_s).join(', ')}"
    else
      species = specieses.first
      species = species.species if species.respond_to? :species
      # updating the id instead of the association doesn't do anything
      fixee.junior_synonym.update_attributes synonym_of: species if fixee.kind_of? Synonym
      fixee.update_attributes fixee_attribute.to_sym => species
    end
  end

end
