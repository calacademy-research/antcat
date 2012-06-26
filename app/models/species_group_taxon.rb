# coding: UTF-8
class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus; validates :genus, presence: true
  belongs_to :subgenus
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
  end

  ##################################################
  # importing

  def self.import data
    transaction do
      protonym = import_protonym data
      species_or_subspecies = get_taxon_class protonym, data[:raw_history]
      species_or_subspecies.import_data protonym, data
    end
  end

  def self.import_protonym data
    protonym = Protonym.import data[:protonym] if data[:protonym]
    raise NoProtonymError unless protonym
    protonym
  end

  def self.get_taxon_class protonym, history
    get_taxon_class_from_history(history) ||
    get_taxon_class_from_protonym(protonym)
  end

  def self.get_taxon_class_from_history history
    return unless history.present?
    get_current_taxon_class(history) ||
    get_latest_taxon_class(history)
  end

  def self.get_current_taxon_class history
    for item in history
      return Subspecies if item[:currently_subspecies_of]
      return Species if item[:subspecies]
    end
    nil
  end

  def self.get_latest_taxon_class history
    klass = nil
    for item in history
      klass = Species if item[:raised_to_species]
    end
    klass
  end

  def self.get_taxon_class_from_protonym protonym
    protonym.name.kind_of?(SubspeciesName) ? Subspecies : Species
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

  def self.import_name data
    Name.import data
  end

  def self.after_creating taxon, data
    taxon.create_history_items data[:history]
    taxon.set_status_from_history data[:raw_history]
  end

  def create_history_items history
    return unless history.present?
    for item in history
      taxonomic_history_items.create! taxt: item
    end
  end

  def set_status_from_history history
    return unless history.present?

    status_record = get_status_from_history history
    if status_record
      update_attributes status: status_record[:status]
      check_synonym_status status_record
    end
  end

  def check_synonym_status status_record
    if status_record[:status] == 'synonym'
      name = SpeciesName.import_data genus: genus, species_epithet: status_record[:parent_epithet]
      ForwardReference.create! fixee: self, fixee_attribute: 'synonym_of', name: name
    end
  end

  def get_status_from_history history
    status = nil
    for item in history
      if item[:synonym_ofs]
        return {status: 'synonym', parent_epithet: item[:species_epithet]}
      elsif item[:homonym_of]
        status = {status: 'homonym'}
      end
    end
    status
  end

  class NoProtonymError < StandardError; end
end
