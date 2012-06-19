# coding: UTF-8
class SpeciesEpithetReference < ForwardReference

  belongs_to :genus; validates :genus, presence: true

  def fixup
    species = self.class.pick_validest Species.find_by_genus_id_and_epithet genus_id, epithet
    if species
      fixee.update_attribute :species, species
    else
      Progress.error "Couldn't find species for genus '#{genus.name}', epithet '#{epithet}'"
    end
  end

  def self.pick_validest targets
    return unless targets
    valid_targets = targets.select {|target| target.status == 'valid'}
    other_targets = targets.select {|target| target.status != 'valid' and target.status != 'homonym'}
    case
    when valid_targets.size > 1 then raise "Too many valid_targets"
    when valid_targets.empty? then other_targets.first
    else valid_targets.first
    end
  end

end
