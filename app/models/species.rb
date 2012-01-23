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

    parts = name.split ' '
    case parts.size
    when 3
      genus_name = parts[0]
      subgenus_epithet = parts[1].gsub(/\(\)/, '')
      species_epithet = parts[2]
    when 2
      genus_name = parts[0]
      species_epithet = parts[1]
    end

    genus = Genus.find attributes[:genus_id]

    species_attributes = {genus: genus, name: species_epithet, status: 'valid', fossil: fossil}
    species = Species.find_by_name_and_genus_id  species_attributes[:name], genus.id
    unless species
      species = Species.create! species_attributes
      Progress.log "FIXUP created species #{species.full_name}"
    end

    species
  end

end
