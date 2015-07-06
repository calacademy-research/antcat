# coding: UTF-8
class Species < SpeciesGroupTaxon
  include Formatters::Formatter

  has_many :subspecies
  attr_accessible :name, :protonym, :genus, :current_valid_taxon, :homonym_replaced_by, :type

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
      raise TaxonExists.new "The subspecies '#{new_name_string}' already exists."
    end


    new_name = SubspeciesName.find_by_name new_name_string
    if new_name.nil?

      new_name = SubspeciesName.new

      new_name.update_attributes({
                                     name: new_name_string,
                                     name_html: italicize(new_name_string),
                                     epithet: name.epithet,
                                     epithet_html: name.epithet_html,
                                     epithets: species.name.epithet + ' ' + name.epithet,
                                 })
      new_name.save
    end

    self.update_columns name_id: new_name.id,
                           species_id: species.id,
                           name_cache: new_name.name,
                           name_html_cache: new_name.name_html,
                           type: 'Subspecies'

  end


  def add_antweb_attributes attributes
    return unless genus
    subfamily_name = genus.subfamily && genus.subfamily.name.to_s || 'incertae_sedis'
    tribe_name = genus.tribe && genus.tribe.name.to_s
    # Sometimes we get names that conform to subspecies format when we parse an invalid.
    # The name will tell us that it's a subspecies name.
    # We should handle that with grace.
    # Really, we should consolidate name handling and unlink it from from all this type-like stuff;
    # because non conforming names are possible, we shouldn't enforce structure on them at all.
    # This would be a pretty major rewrite.
    if name.type == 'SubspeciesName'
      attributes.merge! species: name.epithets.split(' ').first, subspecies: name.epithet
    else
      attributes.merge! species: name.epithet
    end

    attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: genus.name.to_s


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
