class Exporters::Antweb::AntwebAttributes
  include Service

  def initialize taxon
    @taxon = taxon
  end

  def call
    case taxon
    when Family     then family_attributes
    when Subfamily  then subfamily_attributes
    when Tribe      then tribe_attributes
    when Genus      then genus_attributes
    when Subgenus   then subgenus_attributes
    when Species    then species_attributes
    when Subspecies then subspecies_attributes
    else                 {}
    end
  end

  private

    attr_reader :taxon

    delegate :name, :subfamily, :tribe, :genus, :species, to: :taxon

    def family_attributes
      {
        subfamily: 'Formicidae'
      }
    end

    def subfamily_attributes
      {
        subfamily: name.name
      }
    end

    def tribe_attributes
      {
        subfamily: subfamily.name.name,
        tribe: name.name
      }
    end

    def genus_attributes
      {
        subfamily: subfamily&.name&.name || 'incertae_sedis',
        tribe: tribe&.name&.name,
        genus: name.name
      }
    end

    def subgenus_attributes
      {
        subfamily: subfamily&.name&.name || 'incertae_sedis',
        genus: genus&.name&.name,
        subgenus: name.epithet.gsub(/[\(\)]/, '')
      }
    end

    def species_attributes
      {
        subfamily: genus.subfamily&.name&.name || 'incertae_sedis',
        tribe: genus.tribe&.name&.name,
        genus: genus.name.name,
        species: name.epithet
      }
    end

    def subspecies_attributes
      {
        subfamily: genus.subfamily&.name&.name || 'incertae_sedis',
        tribe: genus.tribe&.name&.name,
        genus: genus.name.name,
        species: name.epithets.split.first,
        subspecies: name.epithet
      }
    end
end
