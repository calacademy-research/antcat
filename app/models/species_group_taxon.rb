# coding: UTF-8
class SpeciesGroupTaxon < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  belongs_to :genus; validates :genus, presence: true
  belongs_to :subgenus
  before_create :set_subfamily
  attr_accessible :genus, :subfamily, :subfamily_id

  def recombination?
    genus_epithet = name.genus_epithet
    protonym_genus_epithet = protonym.name.genus_epithet
    genus_epithet != protonym_genus_epithet
  end

  ###########
  def self.import data
    transaction do
      protonym = import_protonym data
      taxon_class = get_taxon_class protonym, data[:raw_history]
      taxon, name = find_taxon_to_update data, taxon_class
      if taxon
        protonym.destroy
        taxon.update_status do
          taxon.update_data data
          after_updating taxon, data
        end
      else
        taxon = taxon_class.import_data protonym, data
      end
      taxon
    end
  end

  def self.import_protonym data
    protonym = Protonym.import data[:protonym] if data[:protonym]
    protonym or raise NoProtonymError
  end

  def self.get_taxon_class protonym, history
    get_taxon_class_from_history(history) or
    get_taxon_class_from_protonym(protonym)
  end

  def self.get_taxon_class_from_protonym protonym
    protonym.name.kind_of?(SubspeciesName) ? Subspecies : Species
  end

  def self.get_taxon_class_from_history history
    history = Importers::Bolton::Catalog::Species::History.new history
    history.taxon_subclass
  end

  def self.import_data protonym, data
    name = import_name data
    taxon = create!(
      genus:      data[:genus],
      name:       name,
      fossil:     data[:fossil] || false,
      status:     data[:status] || 'valid',
      protonym:   protonym,
    )
    after_creating taxon, data
    create_update name, taxon.id, self.name
    taxon
  end

  def self.after_creating taxon, data
    taxon.create_history_items data[:history]
    taxon.set_status_from_history data[:raw_history]
  end

  def self.after_updating taxon, data
    taxon.set_status_from_history data[:raw_history]
  end

  def create_history_items history
    return unless history.present?
    for item in history
      history_items.create! taxt: item
    end
  end

  def set_status_from_history history
    return unless history.present?
    status_record = get_status_from_history history
    before = normalize_field status
    after = normalize_field status_record[:status]
    if before != after
      update_attributes! status: status_record[:status]
    end
    check_synonym_status status_record
  end

  def check_synonym_status status_record
    return unless status_record[:status] == 'synonym'
    create_forward_refs_to_senior_synonyms status_record[:epithets]
  end

  def get_status_from_history history
    history = Importers::Bolton::Catalog::Species::History.new(history)
    {status: history.status, epithets: history.epithets}
  end

  def create_forward_refs_to_senior_synonyms epithets
    for epithet in epithets
      if senior = ForwardRefToSeniorSynonym.find_species_for_fixup(genus, epithet, name.name)
        Synonym.find_or_create self, senior
      else
        synonym = Synonym.find_or_create self, senior
        ForwardRefToSeniorSynonym.create!(
          fixee:            synonym,
          fixee_attribute: 'senior_synonym',
          genus:            genus,
          epithet:          epithet,
        )
      end
    end
  end

  class NoProtonymError < StandardError; end

  def set_subfamily
    # TODO: Rails 4 upgrade breaks this
    # Remove the line below if all tests pass. This is having trouble because it appears that in
    # rails 4, the belongs_to relationship isn't available at this point. Assigning IDs directly.

    #self.subfamily = genus.subfamily if genus
    self.subfamily_id = genus.subfamily.id if genus

  end

  ##################################################
  def self.find_validest_for_epithet_in_genus epithet, genus
    pick_validest find_epithet_in_genus epithet, genus
  end

  def self.pick_validest targets
    return unless targets
    validest = targets.select {|target| target.status == 'valid'}
    if validest.empty?
      validest = targets.select {|target| target.status != 'valid' and target.status != 'homonym'}
    end
    validest.presence
  end

  ##################################################
end
