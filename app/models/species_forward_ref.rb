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
    candidates = Species.find_epithet_in_genus genus_id, epithet
    species = self.class.pick_validest candidates
    if species.nil?
      Progress.error "Couldn't find species '#{epithet}' in genus '#{genus.name}' when fixing up '#{fixee_attribute}' in '#{fixee.name}'"
    else
      fixee.update_attributes fixee_attribute.to_sym => species
    end
  end


  def self.pick_validest targets
    return unless targets
    valid_targets = targets.select {|target| target.status == 'valid'}
    other_targets = targets.select {|target| target.status != 'valid' and target.status != 'homonym'}
    case
    when valid_targets.size > 1
      Progress.error "Found multiple valid targets among #{targets.map(&:name).map(&:to_s).join(', ')}"
      return nil
    when valid_targets.empty? then other_targets.first
    else valid_targets.first
    end
  end

end
