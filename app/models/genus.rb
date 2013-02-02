# coding: UTF-8
class Genus < GenusGroupTaxon
  include Importers::Bolton::Catalog::Updater
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
      history: [],
    )
  end
  def self.import_formicites
    parse_result = Importers::Bolton::Catalog::Subfamily::Grammar.parse(
      '*<i>Formicites</i> Dlussky, 1981: 75. [Collective group name.]', root: :genus_headline).value
    history = Importers::Bolton::Catalog::Importer.convert_line_to_taxt '*<i>Formicites</i> material absorbed into *<i>Eoformica</i>: Dlussky & Rasnitsyn, 2002: 424.'
    genus = import(
      genus_name: 'Formicites',
      status: 'collective group name',
      fossil: true,
      protonym: parse_result[:protonym],
      history: [history],
    )
  end

end
