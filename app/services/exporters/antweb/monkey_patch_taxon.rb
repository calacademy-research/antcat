# HACK: Moved from the main classes. Re-opening the classes here is OK because
# we do not want all this in the main code.
#
# TODO remove monkey patch without adding it to the models.

# To make sure all classes are already loaded
[Family, Subfamily, Tribe, Genus, Subgenus, Species, Subspecies] # rubocop:disable Lint/Void

module Exporters::Antweb::MonkeyPatchTaxon
  class ::Family
    def add_antweb_attributes attributes
      attributes.merge subfamily: 'Formicidae'
    end
  end

  class ::Subfamily
    def add_antweb_attributes attributes
      attributes.merge subfamily: name.to_s
    end
  end

  class ::Tribe
    def add_antweb_attributes attributes
      attributes.merge subfamily: subfamily.name.to_s, tribe: name.to_s
    end
  end

  class ::Genus
    def add_antweb_attributes attributes
      subfamily_name = subfamily && subfamily.name.to_s || 'incertae_sedis'
      tribe_name = tribe && tribe.name.to_s
      attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: name.to_s
    end
  end

  class ::Subgenus
    def add_antweb_attributes attributes
      subfamily_name = subfamily && subfamily.name.to_s || 'incertae_sedis'
      genus_name = genus && genus.name.to_s
      attributes.merge subfamily: subfamily_name, genus: genus_name, subgenus: name.epithet.gsub(/[\(\)]/, '')
    end
  end

  class ::Species
    def add_antweb_attributes attributes
      return unless genus
      subfamily_name = genus.subfamily && genus.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = genus.tribe && genus.tribe.name.to_s
      # Sometimes we get names that conform to subspecies format when we parse an invalid.
      # The name will tell us that it's a subspecies name.
      # We should handle that with grace.
      # Really, we should consolidate name handling and unlink it from from all this type-like stuff;
      # because non conforming names are possible, we shouldn't enforce structure on them at all.
      # This would be a pretty major rewrite.
      if name.type == 'SubspeciesName'
        attributes.merge! species: name.epithets.split(' ').first, subspecies: name.epithet
      else
        attributes.merge! species: name.epithet
      end

      attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: genus.name.to_s
    end
  end

  class ::Subspecies
    def add_antweb_attributes attributes
      # TODO calling methods on nil genera here is the reason for
      # "undefined method `subfamily' for nil:NilClass".
      subfamily_name = genus.subfamily && genus.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = genus.tribe && genus.tribe.name.to_s

      case name
      when SubspeciesName
        attributes.merge! genus: genus.name.to_s,
          species: name.epithets.split(' ').first, subspecies: name.epithet
      when SpeciesName
        attributes.merge! genus: name.to_s.split(' ').first, species: name.epithet
      else
        attributes.merge! genus: genus.name.to_s, species: name.epithet
      end

      attributes.merge subfamily: subfamily_name, tribe: tribe_name
    end
  end
end
