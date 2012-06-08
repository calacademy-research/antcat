# coding: UTF-8
class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species
  has_many :subspecies
  has_many :subgenera

  scope :without_subfamily, where(subfamily_id: nil)
  scope :without_tribe, where(tribe_id: nil)

  def children
    species
  end

  def full_label
    "<i>#{full_name}</i>"
  end

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera.ordered_by_name ||
    subfamily && subfamily.genera.without_tribe.ordered_by_name ||
    Genus.without_subfamily.ordered_by_name
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]
      name = Name.import data[:name]

      headline_notes_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      attributes = {
        subfamily: data[:subfamily],
        tribe: data[:tribe],
        name_object: name,
        fossil: data[:fossil] || false,
        status: data[:status] || 'valid',
        synonym_of: data[:synonym_of],
        protonym: protonym,
        headline_notes_taxt: headline_notes_taxt,
      }
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        type_species_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:type_species][:texts])
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
        ForwardReference.create! source_id: genus.id, target_name: target_name, fossil: type_species[:fossil]
      end

      genus
    end
  end

end
