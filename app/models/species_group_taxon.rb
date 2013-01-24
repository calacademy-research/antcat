# coding: UTF-8
class SpeciesGroupTaxon < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  belongs_to :genus; validates :genus, presence: true
  belongs_to :subgenus
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
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
  def self.import data
    transaction do
      taxon, name = find_taxon_to_update data
      if taxon
        taxon.update_data data
      else
        protonym = import_protonym data
        taxon_class = get_taxon_class protonym, data[:raw_history]
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
    taxon
  end

  def self.after_creating taxon, data
    taxon.create_history_items data[:history]
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
    update_attributes status: status_record[:status]
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
      synonym = Synonym.create! junior_synonym: self
      ForwardRefToSeniorSynonym.create!(
        fixee:            synonym,
        fixee_attribute: 'senior_synonym',
        genus:            genus,
        epithet:          epithet,
      )
    end
  end

  class NoProtonymError < StandardError; end
end
