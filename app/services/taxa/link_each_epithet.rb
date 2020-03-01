module Taxa
  class LinkEachEpithet
    include Service

    def initialize taxon
      @taxon = taxon
    end

    # This links the different parts of the binomial name. Only applicable to
    # species and below, since higher ranks consists of a single word.
    # NOTE: This only works for modern names (rank abbreviations and subgenus parts are ignored).
    def call
      return @taxon.link_to_taxon unless @taxon.is_a? ::SpeciesGroupTaxon

      if @taxon.is_a? Species
        return genus_link << header_link(@taxon, Italicize[@taxon.name.epithet])
      end

      string = genus_link
      string << header_link(@taxon.species, Italicize[@taxon.species.name.epithet])
      string << ' '.html_safe

      if @taxon.is_a? Subspecies
        string << header_link(@taxon, Italicize[@taxon.name.subspecies_epithets])
        return string
      end

      if @taxon.is_a? Infrasubspecies
        string << header_link(@taxon.subspecies, Italicize[@taxon.subspecies.name.epithet])
        string << ' '.html_safe
        string << header_link(@taxon, Italicize[@taxon.name.epithet])
        return string
      end

      raise '???'
    end

    private

      def genus_link
        # Link name of the genus, but add dagger per to taxon's fossil status.
        label = @taxon.genus.name.name_with_fossil_html @taxon.fossil?
        @taxon.genus.decorate.link_to_taxon_with_label(label.html_safe) << " "
      end

      def header_link taxon, label
        taxon.decorate.link_to_taxon_with_label label
      end
  end
end
