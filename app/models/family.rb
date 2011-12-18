# coding: UTF-8
class Family < Taxon

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]
      family = create! :name => 'Formicidae', :status => 'valid', :protonym => protonym
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

  #has_many :tribes, :order => :name
  #has_many :genera, :class_name => 'Genus', :order => :name
  #has_many :species, :class_name => 'Species', :order => :name
  #has_many :subspecies, :class_name => 'Subspecies', :order => :name

  #def children
    #tribes
  #end

  #def full_name
    #name
  #end

  #def full_label
    #full_name
  #end

  #def statistics
    #get_statistics [:genera, :species, :subspecies]
  #end
  def full_label
    name
  end

end
