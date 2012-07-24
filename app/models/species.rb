# coding: UTF-8
class Species < SpeciesGroupTaxon
  has_many :subspecies

  def siblings
    genus.species
  end

  def children
    subspecies
  end

  def statistics
    get_statistics [:subspecies]
  end

  def self.import_myrmicium_heerii
    parse_result = Importers::Bolton::Catalog::Species::Grammar.parse(
      '*<i>heerii</i>. *<i>Myrmicium heerii</i> Westwood, 1854: 396, pl. 18, fig. 21 (wing) GREAT BRITAIN. Transferred to *Myrmiciidae (Symphyta): Maa, 1949: 17; Rasnitsyn, 1969: 17; to *Pseudosiricidae (Symphyta): Handlirsch, 1906: 577; Abe & Smith, D.R. 1991: 53. Excluded from Formicidae.', root: :species_group_record).value
    myrmicium = Genus.find_all_by_name('Myrmicium').where(status: 'excluded').first
    import species_epithet: parse_result[:species_group_epithet],
           fossil: true,
           status: 'excluded',
           genus: myrmicium,
           protonym: parse_result[:protonym],
           raw_history: parse_result[:history],
           history: Importers::Bolton::Catalog::Species::Importer.convert_taxonomic_history_to_taxts(parse_result[:history])
  end

end
