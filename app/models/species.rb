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
      #protonym = Protonym.import data[:protonym]

      #headline_notes_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      attributes = {
        #subfamily: data[:subfamily],
        #tribe: data[:tribe],
        genus: data[:genus],
        name: data[:name],
        fossil: data[:fossil] || false,
        status: data[:status] || 'valid',
        #synonym_of: data[:synonym_of],
        #protonym: protonym,
        #headline_notes_taxt: headline_notes_taxt,
      }
      #attributes.merge! data[:attributes] if data[:attributes]
      #if data[:type_species]
        #type_species_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:type_species][:texts])
        #attributes[:type_taxon_taxt] = type_species_taxt
      #end
      species = create! attributes
      #data[:taxonomic_history].each do |item|
        #genus.taxonomic_history_items.create! taxt: item
      #end

      #type_species = data[:type_species]
      #if type_species
        #target_name = type_species[:genus_name]
        #target_name << ' (' << type_species[:subgenus_epithet] + ')' if type_species[:subgenus_epithet]
        #target_name << ' '  << type_species[:species_epithet]
        #ForwardReference.create! source_id: genus.id, target_name: target_name, fossil: type_species[:fossil]
      #end

      #genus
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
