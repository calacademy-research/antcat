# frozen_string_literal: true

module Taxa
  class LinkEachEpithet
    include Service

    attr_private_initialize :taxon

    # This links the different parts of the name for species and below,
    # and just the name for uninomials.
    def call
      return CatalogFormatter.link_to_taxon(taxon) unless taxon.is_a?(::SpeciesGroupTaxon)

      if taxon.is_a?(Species)
        return genus_link << name_part_link(taxon, taxon.name.epithet)
      end

      string = genus_link
      string << name_part_link(taxon.species, taxon.species.name.epithet)
      string << ' '.html_safe

      if taxon.is_a?(Subspecies)
        string << name_part_link(taxon, taxon.name.epithet)
        string
      elsif taxon.is_a?(Infrasubspecies)
        string << name_part_link(taxon.subspecies, taxon.subspecies.name.epithet)
        string << ' '.html_safe
        string << name_part_link(taxon, taxon.name.epithet)
        string
      end
    end

    private

      def genus_link
        # Link name of the genus, but add dagger per taxon's fossil status.
        label = taxon.genus.name.name_with_fossil_html taxon.fossil?
        CatalogFormatter.link_to_taxon_with_label(taxon.genus, label) << " "
      end

      def name_part_link taxon, label
        CatalogFormatter.link_to_taxon_with_label(taxon, Italicize[label])
      end
  end
end
