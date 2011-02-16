class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, :class_name => 'Species', :order => :name

  def children
    species
  end

  def self.import record
    subfamily_name = record[:subfamily]
    tribe_name = record[:tribe]
    synonym_of_name = record[:synonym_of]
    homonym_of_name = record[:homonym_of]

    subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name, :status => 'valid')
    raise if subfamily && !subfamily.valid?

    tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :subfamily => subfamily, :status => 'valid')
    raise if tribe && !tribe.valid?

    synonym_of = synonym_of_name && Genus.find_or_create_by_name(synonym_of_name, :status => 'valid')
    raise if synonym_of && !synonym_of.valid?

    homonym_of = homonym_of_name && Genus.find_or_create_by_name(homonym_of_name, :status => 'valid')
    raise if homonym_of && !homonym_of.valid?

    incertae_sedis_in = record[:incertae_sedis_in] && record[:incertae_sedis_in].to_s

    genus = Genus.find_or_create_by_name record[:name],
      :fossil => record[:fossil], :status => record[:status].to_s,
      :subfamily => subfamily, :tribe => tribe, 
      :synonym_of => synonym_of, :homonym_of => homonym_of,
      :taxonomic_history => record[:taxonomic_history],
      :incertae_sedis_in => incertae_sedis_in
    raise unless genus.valid?
    genus
  end

end
