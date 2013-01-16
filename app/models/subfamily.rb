# coding: UTF-8
class Subfamily < Taxon
  include Updater
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names, class_name: 'Genus', conditions: 'status = "collective group name"'

  def self.import data
    name = Name.import data
    transaction do
      if subfamily = find_by_name(name.name)
        subfamily.update_data data
      else
        attributes = {
          name:                name,
          fossil:              data[:fossil] || false,
          status:              data[:status] ||'valid',
          protonym:            Protonym.import(data[:protonym]),
          headline_notes_taxt: data[:headline_notes_taxt],
        }
        attributes.merge! get_type_attributes :type_genus, data
        subfamily = create! attributes
        data[:history].each do |item|
          subfamily.history_items.create! taxt: item
        end
      end
      subfamily
    end
  end

  def update_data data
    attributes = {}

    update_boolean_field  'fossil',              data[:fossil], attributes
    update_field          'status',              data[:status] || 'valid', attributes
    update_taxt_field     'headline_notes_taxt', data[:note], attributes

    type_attributes = self.class.get_type_attributes :type_genus, data
    update_name_field     'type_name',    type_attributes[:type_name], attributes
    update_field          'type_taxt',    type_attributes[:type_taxt], attributes
    update_boolean_field  'type_fossil',  type_attributes[:type_fossil], attributes

    update_attributes attributes

    protonym.update_data data[:protonym]
    update_history data[:history]
  end

  #########

  def children
    tribes
  end

  def statistics
    get_statistics [:tribes, :genera, :species, :subspecies]
  end

end
