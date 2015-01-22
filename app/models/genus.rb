# coding: UTF-8
class Genus < GenusGroupTaxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :tribe
  has_many :species
  has_many :subspecies
  has_many :subgenera

  scope :without_subfamily, -> { where(subfamily_id: nil) }
  scope :without_tribe, -> { where(tribe_id: nil) }

  def update_parent new_parent
    set_name_caches
    case
    when new_parent.kind_of?(Tribe)
      self.tribe = new_parent
      self.subfamily = new_parent.subfamily
    when new_parent.kind_of?(Subfamily)
      self.tribe = nil
      self.subfamily = new_parent
    when new_parent.nil?
      self.tribe = nil
      self.subfamily = nil
    end
    update_descendants_subfamilies
  end

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera.ordered_by_name ||
    subfamily && subfamily.genera.without_tribe.ordered_by_name ||
    Genus.without_subfamily.ordered_by_name
  end

  def species_group_descendants
    Taxon.where(genus_id: id).where('taxa.type != ?', 'subgenus').includes(:name).order('names.epithet')
  end

  def add_antweb_attributes attributes
    subfamily_name = subfamily && subfamily.name.to_s || 'incertae_sedis'
    tribe_name = tribe && tribe.name.to_s
    attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: name.to_s
  end

  def self.import_attaichnus subfamily, tribe
    note = Importers::Bolton::Catalog::Grammar.parse(%{Included ichnospecies: *<i>Attaichnus kuenzelii</i>. [Ichnofossil, purportedly fossil traces of workings attributable to attine ants.]}, root: :texts).value[:texts]
    import(
      genus_name: 'Attaichnus',
      subfamily: subfamily,
      tribe: tribe,
      status: 'valid',
      ichnotaxon: true,
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

  private

  def update_descendants_subfamilies
    self.species.each{ |s| s.subfamily = self.subfamily }
    self.subspecies.each{ |s| s.subfamily = self.subfamily }
  end

end
