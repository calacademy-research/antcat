# coding: UTF-8
class Family < Taxon

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]
      family = create! :name => 'Formicidae', :status => 'valid', :protonym => protonym
      data[:taxonomic_history].each do |item|
        family.taxonomic_history_items.create! :text => item
      end
      ForwardReference.create! :source_id => family.id, :source_attribute => :type_taxon, :target_name => data[:type_genus]
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

end
