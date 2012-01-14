# coding: UTF-8
class Species < Taxon
  belongs_to :subfamily
  belongs_to :genus
  has_many :subspecies, :class_name => 'Subspecies', :order => :name
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
  end

  def children
    subspecies
  end

  def full_name
    "#{genus.name} #{name}"
  end

  def full_label
    "<i>#{full_name}</i>"
  end

  def statistics
    get_statistics [:subspecies]
  end

  def siblings
    genus.species
  end

  def self.create_from_fixup attributes
    name = attributes[:name]

    genus_attributes = {:name => name.split.first, :status => 'valid'}
    genus = Genus.find_by_name  genus_attributes[:name]
    unless genus
      genus = Genus.create! genus_attributes
      Progress.log "FIXUP created genus #{genus.name}"
    end

    species_attributes = {:name => name.split.second, :status => 'valid'}
    species = Species.find_by_name  species_attributes[:name]
    unless species
      species = Species.create! species_attributes.merge :genus => genus
      Progress.log "FIXUP created species #{genus.name} #{species.name}"
    end

    species
  end

end
