class Subgenus < Taxon
  belongs_to :genus
  has_many :species, :class_name => 'Species', :order => :name
  validates_presence_of :genus

  def children
    species
  end

  def self.import record
    genus_name = record[:genus]
    status = record[:status].to_s

    genus = genus_name && Genus.find_or_create_by_name(genus_name)
    raise if genus && !genus.valid?

    attributes = {:name => record[:name], :fossil => record[:fossil], :status => record[:status].to_s,
                  :genus => genus, :taxonomic_history => record[:taxonomic_history]}

    existing_genus = Genus.find_by_name record[:name]
    if existing_genus
      existing_genus = existing_genus.becomes(Subgenus)
      existing_genus.type = 'Subgenus'
      existing_genus.update_attributes! attributes
      existing_genus
    else
      create! attributes
    end
  end

end
