# frozen_string_literal: true

module Taxa
  class LinkEachEpithet
    include Service

    attr_private_initialize :taxon

    # This links the different parts of the binomial name. Only applicable to
    # species and below, since higher ranks consists of a single word.
    # NOTE: This only works for modern names (rank abbreviations and subgenus parts are ignored).
    def call
      return CatalogFormatter.link_to_taxon(taxon) unless taxon.is_a?(::SpeciesGroupTaxon)

      if taxon.is_a?(Species)
        return genus_link << header_link(taxon, taxon.name.epithet)
      end

      string = genus_link
      string << header_link(taxon.species, taxon.species.name.epithet)
      string << ' '.html_safe

      if taxon.is_a?(Subspecies)
        # TODO: Probably change to `#epithet`.
        string << header_link(taxon, taxon.name.subspecies_epithet)
        string
      elsif taxon.is_a?(Infrasubspecies)
        string << header_link(taxon.subspecies, taxon.subspecies.name.epithet)
        string << ' '.html_safe
        string << header_link(taxon, taxon.name.epithet)
        string
      end
    end

    private

      def genus_link
        # Link name of the genus, but add dagger per taxon's fossil status.
        label = taxon.genus.name.name_with_fossil_html taxon.fossil?
        CatalogFormatter.link_to_taxon_with_label(taxon.genus, label) << " "
      end

      def header_link taxon, label
        CatalogFormatter.link_to_taxon_with_label(taxon, Italicize[label])
      end
  end
end
