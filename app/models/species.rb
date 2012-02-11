# coding: UTF-8
class Species < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus
  has_many :subspecies, class_name: 'Subspecies', order: :name
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
    fossil = attributes[:fossil] || false

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

    if attributes[:genus_id]
      taxon = Genus.find attributes[:genus_id]
      genus = taxon
    elsif attributes[:subgenus_id]
      taxon = Subgenus.find attributes[:subgenus_id]
      genus = taxon.genus
    else raise
    end

    species_attributes = {genus: genus, name: species_epithet, status: 'valid', fossil: fossil}
    species_attributes[:subgenus_id] = attributes[:subgenus_id] if attributes[:subgenus_id]

    if attributes[:genus_id]
      species = Species.find_by_name_and_genus_id  species_attributes[:name], taxon.id
    elsif attributes[:subgenus_id]
      species = Species.find_by_name_and_subgenus_id  species_attributes[:name], taxon.id
    else raise
    end

    unless species
      species = Species.create! species_attributes
      Progress.log "FIXUP created species #{species.full_name}"
    end

    species
  end

end
