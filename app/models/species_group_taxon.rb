# coding: UTF-8
class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
  end

  def children
    subspecies
  end

  def statistics
    get_statistics [:subspecies]
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym] if data[:protonym]
      raise NoProtonymError unless protonym
      get_taxon_class(protonym, data[:raw_history]).import_data protonym, data
    end
  end

  def self.get_taxon_class protonym, history
    get_taxon_class_from_history(history) || get_taxon_class_from_protonym(protonym)
  end

  def self.get_taxon_class_from_history history
    for item in history or []
      return Subspecies if item[:currently_subspecies_of]
      return Species if item[:subspecies]
    end
    for item in history or []
      return Species if item[:raised_to_species]
    end
    nil
  end

  def self.get_taxon_class_from_protonym protonym
    protonym.name.kind_of?(SubspeciesName) ? Subspecies : Species
  end

  def self.import_data protonym, data
    name = import_name data

    attributes = {
      genus:      data[:genus],
      name:       name,
      fossil:     data[:fossil] || false,
      status:     data[:status] || 'valid',
      protonym:   protonym,
    }

    species_group_taxon = create! attributes

    species_group_taxon.do_stuff_after_creating_taxon data

    (data[:history] || []).each do |item|
      species_group_taxon.taxonomic_history_items.create! taxt: item
    end

    species_group_taxon
  end

  def do_stuff_after_creating_taxon data
    set_status_from_history data[:raw_history]
  end

  def set_status_from_history history
    return unless history.present?

    status_record = get_status_from_history history
    update_attributes status: status_record[:status] if status_record

    check_synonym_status status_record
  end

  def check_synonym_status status_record
    if status_record && status_record[:synonym]
      name = SpeciesName.import genus: genus, epithet: status_record[:parent_epithet]
      ForwardReference.create! fixee: self, fixee_attribute: 'synonym_of', name: name
    end
  end

  def get_status_from_history history
    status = nil
    for item in history
      if item[:synonym_ofs]
        return {status: 'synonym', parent_epithet: item[:species_group_epithet]}
      elsif item[:homonym_of]
        status = {status: 'homonym'}
      end
    end
    status
  end

  class NoProtonymError < StandardError; end
end
