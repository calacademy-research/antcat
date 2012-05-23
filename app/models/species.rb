# coding: UTF-8
class Species < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus
  has_many :subspecies, order: :name
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

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym] if data[:protonym]

      attributes = {
        genus: data[:genus],
        name: data[:name],
        fossil: data[:fossil] || false,
        status: data[:status] || 'valid',
        protonym: protonym,
      }

      species = create! attributes
      data[:history].each do |item|
        species.taxonomic_history_items.create! taxt: item
      end
      set_status_from_history species, data[:raw_history]

      species
    end
  end

  def self.set_status_from_history species, history
    return unless history
    synonym_of = history.first[:synonym_ofs].try :first
    if synonym_of
      genus = species.genus
      senior_name = synonym_of[:species_epithet]
      senior = Species.find_by_genus_id_and_name genus.id, senior_name
      if senior
        species.update_attributes status: 'synonym', synonym_of: senior
      else
        ForwardReference.create! source_id: species.id, target_parent: genus.id, target_name: senior_name
      end
    else
      species.update_attributes status: 'valid'
    end
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
