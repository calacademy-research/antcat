# coding: UTF-8
class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus; validates :genus, presence: true
  belongs_to :subgenus
  before_create :set_subfamily
  attr_accessible :genus, :subfamily, :subfamily_id,:type_name_id

  def recombination?
    genus_epithet = name.genus_epithet
    protonym_genus_epithet = protonym.name.genus_epithet
    genus_epithet != protonym_genus_epithet
  end

  class NoProtonymError < StandardError; end

  def set_subfamily
    # TODO: Rails 4 upgrade breaks this
    # Remove the line below if all tests pass. This is having trouble because it appears that in
    # rails 4, the belongs_to relationship isn't available at this point. Assigning IDs directly.

    #self.subfamily = genus.subfamily if genus
    self.subfamily_id = genus.subfamily.id if genus and genus.subfamily
  end

  ##################################################
  def self.find_validest_for_epithet_in_genus epithet, genus
    pick_validest find_epithet_in_genus epithet, genus
  end

  def self.pick_validest targets
    return unless targets
    validest = targets.select {|target| target.status == 'valid'}
    if validest.empty?
      validest = targets.select {|target| target.status != 'valid' and target.status != 'homonym'}
    end
    validest.presence
  end
end