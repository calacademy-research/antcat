# coding: UTF-8
class Species < SpeciesGroupTaxon
  include Formatters::Formatter

  has_many :subspecies
  attr_accessible :name, :protonym, :genus, :current_valid_taxon, :homonym_replaced_by

  def siblings
    genus.species
  end

  def children
    subspecies
  end

  def statistics
    get_statistics [:subspecies]
  end

  def become_subspecies_of species
    new_name_string = species.genus.name.to_s + ' ' + species.name.epithet + ' ' + name.epithet
    if Subspecies.find_by_name new_name_string
      raise TaxonExists.new "The subspecies '#{new_name_string}' already exists. Please tell Mark."
    end
    new_name = SubspeciesName.find_by_name new_name_string
    new_name ||= SubspeciesName.new
    new_name.update_attributes({
      name:           new_name_string,
      name_html:      italicize(new_name_string),
      epithet:        name.epithet,
      epithet_html:   name.epithet_html,
      epithets:       species.name.epithet + ' ' + name.epithet,
    })
    update_column :type, 'Subspecies'
    Subspecies.find(id).update_attributes name: new_name, species: species
  end

  def add_antweb_attributes attributes
    return unless genus
    subfamily_name = genus.subfamily && genus.subfamily.name.to_s || 'incertae_sedis'
    tribe_name = genus.tribe && genus.tribe.name.to_s
    attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: genus.name.to_s, species: name.epithet
  end

  def self.import_myrmicium_heerii
    parse_result = Importers::Bolton::Catalog::Species::Grammar.parse(
      '*<i>heerii</i>. *<i>Myrmicium heerii</i> Westwood, 1854: 396, pl. 18, fig. 21 (wing) GREAT BRITAIN. Transferred to *Myrmiciidae (Symphyta): Maa, 1949: 17; Rasnitsyn, 1969: 17; to *Pseudosiricidae (Symphyta): Handlirsch, 1906: 577; Abe & Smith, D.R. 1991: 53. Excluded from Formicidae.', root: :species_group_record).value
    myrmicium = Genus.find_all_by_name('Myrmicium').where(status: 'excluded from Formicidae').first
    import species_epithet: parse_result[:species_group_epithet],
           fossil: true,
           status: 'excluded from Formicidae',
           genus: myrmicium,
           protonym: parse_result[:protonym],
           raw_history: parse_result[:history],
           history: Importers::Bolton::Catalog::Species::Importer.convert_history_to_taxts(parse_result[:history])
  end

end
