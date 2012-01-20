# coding: UTF-8
class Family < Taxon

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]
      type_taxon_name = Taxt.encode_taxon_name data[:type_genus][:genus_name], :genus, data[:type_genus]
      type_taxon_taxt = Bolton::Catalog::TextToTaxt.convert(data[:type_genus][:texts])
      headline_notes_taxt = Bolton::Catalog::TextToTaxt.convert(data[:note])

      family = create! name: 'Formicidae', status: 'valid', protonym: protonym,
                       type_taxon_name: type_taxon_name,
                       type_taxon_taxt: type_taxon_taxt,
                       headline_notes_taxt: headline_notes_taxt

      data[:taxonomic_history].each {|item| family.taxonomic_history_items.create! :taxt => item}

      ForwardReference.create! :source_id => family.id, :source_attribute => :type_taxon,
                               :target_name => data[:type_genus][:genus_name]
      family
    end
  end

  def statistics
    get_statistics [[Subfamily, :subfamilies], [Genus, :genera], [Species, :species], [Subspecies, :subspecies]]
  end

  def get_statistics ranks
    statistics = {}
    ranks.each do |klass, rank|
      count = klass.count :group => [:fossil, :status]
      self.class.massage_count count, rank, statistics
    end
    statistics
  end

  def full_label
    name
  end

  def full_name
    name
  end

end
