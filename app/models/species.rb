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
    fossil = attributes[:fossil]
    genus_name = name.split.first
    species_epithet = name.split.second
    genus = Genus.find attributes[:genus_id]

    raise "Fixing up '#{name}' in genus '#{genus.name}'" unless genus_name == genus.name

    species_attributes = {genus: genus, name: species_epithet, status: 'valid', fossil: fossil}
    species = Species.find_by_name_and_genus_id  species_attributes[:name], genus.id
    unless species
      species = Species.create! species_attributes
      Progress.log "FIXUP created species #{genus_name} #{species_epithet} #{fossil ? '(fossil)' : ''}"
    end

    species
  end

end
