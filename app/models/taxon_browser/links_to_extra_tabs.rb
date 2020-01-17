module TaxonBrowser
  class LinksToExtraTabs
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      links_to_extra_tabs.map do |(label, display)|
        { label: label, display: display }
      end
    end

    private

      attr_reader :taxon

      def links_to_extra_tabs
        links = []

        case taxon
        when Family
          links << ["All genera",     Tab::ALL_GENERA_IN_FAMILY]
          links << ["Incertae sedis", Tab::INCERTAE_SEDIS_IN_FAMILY] if taxon.genera_incertae_sedis_in.exists?
        when Subfamily
          links << ["All genera",     Tab::ALL_GENERA_IN_SUBFAMILY]
          links << ["Without tribe",  Tab::GENERA_WITHOUT_TRIBE]
          links << ["Incertae sedis", Tab::INCERTAE_SEDIS_IN_SUBFAMILY] if taxon.genera_incertae_sedis_in.exists?
        when Tribe
          links << ["Subtribes",      Tab::SUBTRIBES_IN_TRIBE] if taxon.subtribes.exists?
        when Genus
          links << ["All taxa",       Tab::ALL_TAXA_IN_GENUS]
          if taxon.subgenera.exists?
            links << ["Subgenera",        Tab::SUBGENERA_IN_GENUS]
            links << ["Without subgenus", Tab::SPECIES_WITHOUT_SUBGENUS]
          end
        end

        links.reject(&:blank?)
      end
  end
end
