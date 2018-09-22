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
      return {} unless genus

      attributes = {
        subfamily: genus&.subfamily&.name&.name || 'incertae_sedis',
        tribe: genus&.tribe&.name&.name,
        genus: genus.name.name
      }

      # TODO: hmm.
      if name.is_a? SubspeciesName
        attributes.merge!(
          species: name.epithets.split(' ').first,
          subspecies: name.epithet
        )
      else
        attributes.merge! species: name.epithet
      end

      attributes
    end

    def subspecies_attributes
      attributes = {
        subfamily: genus&.subfamily&.name&.name || 'incertae_sedis',
        tribe: genus&.tribe&.name&.name
      }

      # TODO: hmm.
      case name
      when SubspeciesName
        attributes.merge!(
          genus: genus.name.name,
          species: name.epithets.split(' ').first,
          subspecies: name.epithet
        )
      when SpeciesName
        attributes.merge!(
          genus: name.name.split(' ').first,
          species: name.epithet
        )
      else
        attributes.merge!(
          genus: genus.name.name,
          species: name.epithet
        )
      end

      attributes
    end
end
