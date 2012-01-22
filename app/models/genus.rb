# coding: UTF-8
class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, class_name: 'Species', order: :name
  has_many :subspecies, class_name: 'Subspecies', order: :name
  has_many :subgenera, class_name: 'Subgenus', order: :name

  scope :without_subfamily, where(subfamily_id: nil).order(:name)
  scope :without_tribe, where(tribe_id: nil)

  def children
    species
  end

  def full_label
    "<i>#{full_name}</i>"
  end

  def full_name
    name
  end

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera ||
    subfamily && subfamily.genera.without_tribe.all ||
    Genus.without_subfamily.all
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]

      headline_notes_taxt = Bolton::Catalog::TextToTaxt.convert(data[:note])
      attributes = {
        subfamily: data[:subfamily],
        name: data[:name],
        fossil: data[:fossil],
        status: 'valid',
        protonym: protonym,
        headline_notes_taxt: headline_notes_taxt,
      }
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        type_species_taxt = Bolton::Catalog::TextToTaxt.convert(data[:type_species][:texts])
        attributes[:type_taxon_taxt] = type_species_taxt
      end
      genus = create! attributes
      data[:taxonomic_history].each do |item|
        genus.taxonomic_history_items.create! taxt: item
      end

      type_species = data[:type_species]
      if type_species
        target_name = type_species[:genus_name]
        target_name << ' (' << type_species[:subgenus_epithet] + ')' if type_species[:subgenus_epithet]
        target_name << ' '  << type_species[:species_epithet]
        ForwardReference.create! source_id: genus.id, source_attribute: :type_taxon, target_name: target_name,
          fossil: type_species[:fossil]
      end

      genus
    end
  end

  def self.create_from_fixup attributes
    name = attributes[:name]
    fossil = attributes[:fossil]
    subfamily_id = attributes[:subfamily_id]

    genus = Genus.find_by_name name
    unless genus
      genus = Genus.create! name: name, status: 'valid', fossil: fossil, subfamily_id: subfamily_id
      Progress.log "FIXUP created genus #{genus.full_name}"
    end

    genus
  end


end
