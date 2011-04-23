class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, :class_name => 'Species', :order => :name
  has_many :subspecies, :class_name => 'Subspecies', :order => :name
  has_many :subgenera, :class_name => 'Subgenus', :order => :name

  def children
    species
  end

  def self.import record
    subfamily_name = record[:subfamily]
    tribe_name = record[:tribe]
    synonym_of_name = record[:synonym_of]
    homonym_resolved_to_name = record[:homonym_resolved_to]
    status = record[:status].present? ? record[:status] : nil
    incertae_sedis_in = record[:incertae_sedis_in] && record[:incertae_sedis_in]
    fossil = record[:fossil]

    # the parse returns subfamilies that are outside the family - exclude them
    subfamily_name = nil if ['Aculeata', 'Symphyta', 'Apocrita', 'Homoptera', 'Ichneumonidae', 'Embolemidae'].include? subfamily_name

    subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name, :status => 'valid')
    raise if subfamily && !subfamily.valid?

    tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :subfamily => subfamily, :status => 'valid')
    raise if tribe && !tribe.valid?

    synonym_of = find_referent synonym_of_name
    homonym_resolved_to = find_referent homonym_resolved_to_name

    # sorry, Barry, but it's just not
    fossil = nil if record[:name] == 'Pseudoatta'

    attributes = {:name => record[:name], :fossil => fossil, :status => status,
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
      already_printed_genus_name = false
      existing_genus = possible_matches.find {|possible_match| possible_match.status == status}
      if subfamily && existing_genus.subfamily && existing_genus.subfamily != subfamily
        raise "#{existing_genus.name}: trying to replace subfamily '#{existing_genus.subfamily && existing_genus.subfamily.name}' with '#{subfamily_name}'"
      end
      if tribe && existing_genus.tribe && existing_genus.tribe != tribe
        raise "#{existing_genus.name}: trying to replace tribe '#{existing_genus.tribe && existing_genus.tribe.name}' with '#{tribe_name}'"
      end
      if !!existing_genus.fossil? != !!fossil
        raise "#{existing_genus.name}: trying to replace fossil flag '#{existing_genus.fossil?}' with '#{fossil}'"
      end
    end
    genus
  end

  def self.find_referent name
    return unless name
    find_by_name(name) || Subgenus.find_by_name(name) || create!(:name => name)
  end

  def full_name
    full_name = "<i>#{name}</i>"
    full_name = "#{subfamily.name} " + full_name if subfamily
    full_name
  end

  def statistics
    {:species => species.count(:group => :status),
     :subspecies => subspecies.count(:group => :status),
    }
  end

end
