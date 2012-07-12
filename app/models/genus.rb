# coding: UTF-8
class Genus < GenusGroupTaxon
  belongs_to :tribe
  has_many :species
  has_many :subspecies
  has_many :subgenera

  scope :without_subfamily, where(subfamily_id: nil)
  scope :without_tribe, where(tribe_id: nil)

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera.ordered_by_name ||
    subfamily && subfamily.genera.without_tribe.ordered_by_name ||
    Genus.without_subfamily.ordered_by_name
  end

  def species_group_descendants
    Taxon.where(genus_id: id).where('taxa.type != ?', 'subgenus').joins(:name).order('names.epithet')
  end

  def self.import data, attributes = {}
    transaction do
      attributes.merge!(
        name:                 Name.import(data),
        fossil:               data[:fossil] || false,
        status:               data[:status] || 'valid',
        protonym:             Protonym.import(data[:protonym]),
        subfamily:            data[:subfamily],
        tribe:                data[:tribe],
        synonym_of:           data[:synonym_of],
        headline_notes_taxt:  Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      )
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        attributes[:type_name] = Name.import data[:type_species]
        attributes[:type_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[:type_species][:texts]
      end
      genus = create! attributes
      genus.import_synonyms attributes
      genus.import_taxonomic_history data
      genus
    end
  end

  def import_taxonomic_history data
    for item in data[:taxonomic_history]
      taxonomic_history_items.create! taxt: item if item.present?
    end
  end

  def self.import_attaichnus subfamily, tribe
    note = Importers::Bolton::Catalog::Grammar.parse(%{Included ichnospecies: *<i>Attaichnus kuenzelii</i>. [Ichnofossil, purportedly fossil traces of workings attributable to attine ants.]}, root: :texts).value[:texts]
    import(
      genus_name: 'Attaichnus',
      subfamily: subfamily,
      tribe: tribe,
      status: 'ichnotaxon',
      fossil: true,
      protonym: {genus_name: 'Attaichnus', authorship: [{author_names: ['Laza'], year: '1982', pages: '112', matched_text: 'Laza, 1982: 112'}]},
      note: note,
      taxonomic_history: [],
    )
  end

end
