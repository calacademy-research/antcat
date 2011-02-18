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
    homonym_resolved_to_name = record[:homonym_resolved_to]
    status = record[:status].to_s
    incertae_sedis_in = record[:incertae_sedis_in] && record[:incertae_sedis_in].to_s

    subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name, :status => 'valid')
    raise if subfamily && !subfamily.valid?

    tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :subfamily => subfamily, :status => 'valid')
    raise if tribe && !tribe.valid?

    synonym_of = synonym_of_name && find_or_create_by_name(synonym_of_name)
    raise if synonym_of && !synonym_of.valid?

    homonym_resolved_to = homonym_resolved_to_name && find_or_create_by_name(homonym_resolved_to_name)
    raise if homonym_resolved_to && !homonym_resolved_to.valid?

    attributes = {:name => record[:name], :fossil => record[:fossil], :status => status,
                  :subfamily => subfamily, :tribe => tribe, 
                  :synonym_of => synonym_of, :homonym_resolved_to => homonym_resolved_to,
                  :taxonomic_history => record[:taxonomic_history],
                  :incertae_sedis_in => incertae_sedis_in}

    possible_matches = Genus.all :conditions => ['name = ?', record[:name]]
    if genus = possible_matches.find {|possible_match| possible_match.status.nil?}
      genus.update_attributes! attributes
    elsif possible_matches.none? {|possible_match| possible_match.status == status}
      genus = create! attributes
    else
      
      raise "Trying to add the genus #{record[:name]} twice with the same status"
    end
    genus
  end

end
