# coding: UTF-8
class Family < Taxon
  include Updater

  def self.import data
    name = Name.import family_name: 'Formicidae'
    transaction do
      if family = find_by_name(name.name)
        family.update_data data
      else
        attributes = {
          name:                name,
          fossil:              false,
          status:              'valid',
          protonym:            Protonym.import(data[:protonym]),
          headline_notes_taxt: Importers::Bolton::Catalog::TextToTaxt.convert(data[:note]),
        }
        attributes.merge! get_type_attributes :type_genus, data
        family = create! attributes
        data[:history].each do |item|
          family.history_items.create! taxt: item
        end
      end
      family
    end
  end

  def update_data data
    attributes = {}
    update_field 'fossil', data[:fossil], attributes
    update_field 'status', data[:status], attributes
    update_taxt_field 'headline_notes_taxt', data[:note], attributes
    type_attributes = self.class.get_type_attributes :type_genus, data
    update_name_field 'type_name', type_attributes[:type_name], attributes
    update_field 'type_taxt', type_attributes[:type_taxt], attributes
    update_field 'type_fossil', type_attributes[:type_fossil], attributes
    update_attributes attributes
    protonym.update_data data[:protonym]
    update_history data[:history]
  end

  def update_history history_data
    # compare and update common subset
    i = 0
    while i < history_items.count && i < history_data.count
      item = history_items.all[i]
      before = item.taxt
      after = history_data[i]
      if before != after
        Update.create! class_name: 'TaxonHistoryItem', record_id: item.id, field_name: 'taxt',
          before: before, after: after
        item.update_attributes taxt: after
      end
      i += 1
    end
    # add new ones
    while i < history_data.count
      new_taxt = history_data[i]
      new_item = history_items.create! taxt: new_taxt
      Update.create! class_name: 'TaxonHistoryItem', record_id: new_item.id,
        field_name: 'taxt', before: nil, after: new_taxt
      i += 1
    end
    # delete deleted ones
    items_to_delete = []
    while i < history_items.count
      items_to_delete << history_items[i].id
      Update.create! class_name: 'TaxonHistoryItem', record_id: history_items[i].id,
        field_name: 'taxt', before: nil, after: nil
      i += 1
    end
    items_to_delete.each {|item| TaxonHistoryItem.delete item}
  end

  def import_reference_sections sections
    # compare and update common subset
    i = 0
    while i < reference_sections.count && i < sections.count
      item = reference_sections.all[i]
      for field_name in ['title', 'subtitle', 'references']
        update_reference_section_field field_name, item, sections[i]
      end
      i += 1
    end
    # add new ones
    while i < sections.count
      new_section = sections[i]
      new_item = reference_sections.create! new_section
      for field_name in ['title', 'subtitle', 'references']
        Update.create! class_name: 'ReferenceSection', record_id: new_item.id,
          field_name: field_name, before: nil, after: new_section[:title]
      end
      i += 1
    end
    # delete deleted ones
    items_to_delete = []
    while i < history_items.count
      items_to_delete << reference_sections[i].id
      Update.create! class_name: 'ReferenceSection', record_id: reference_sections[i].id,
        field_name: nil, before: nil, after: nil
      i += 1
    end
    items_to_delete.each {|item| ReferenceSection.delete item}
  end

  def update_reference_section_field field_name, old_section, new_section
    before = old_section[field_name.to_sym]
    after = new_section[field_name.to_sym]
    if before != after
      Update.create! class_name: 'ReferenceSection', record_id: old_section.id, field_name: field_name,
        before: before, after: after
      old_section.update_attributes field_name => after
    end
  end

  ##########

  def genera
    Genus.without_subfamily.ordered_by_name
  end

  def subfamilies
    Subfamily.ordered_by_name
  end

  def statistics
    get_statistics Subfamily, Tribe, Genus, Species, Subspecies
  end

  def get_statistics *ranks
    ranks.inject({}) do |statistics, klass|
      count = klass.count :group => [:fossil, :status]
      self.class.massage_count count, Rank[klass].to_sym(:plural), statistics
      statistics
    end
  end

end
