# coding: UTF-8
class Family < Taxon

  def self.import data
    transaction do
      name = Name.import family_name: 'Formicidae'
      protonym = Protonym.import data[:protonym]
      type_name = Name.import data[:type_genus]
      type_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:type_genus][:texts])
      headline_notes_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])

      family = create! name:         name,
                       status:              'valid',
                       protonym:            protonym,
                       type_name:           type_name,
                       type_taxt:           type_taxt,
                       headline_notes_taxt: headline_notes_taxt

      data[:taxonomic_history].each {|item| family.taxonomic_history_items.create! :taxt => item}

      family
    end
  end

  def statistics
    get_statistics Tribe, Subfamily, Genus, Species, Subspecies
  end

  def get_statistics *ranks
    ranks.inject({}) do |statistics, klass|
      count = klass.count :group => [:fossil, :status]
      self.class.massage_count count, Rank[klass].to_sym(:plural), statistics
      statistics
    end
  end

end
