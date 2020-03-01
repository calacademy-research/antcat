module Exporters
  module Antweb
    class ExportHeadlineType
      include Service

      def initialize taxon
        @taxon = taxon
      end

      def call
        headline_type
      end

      private

        attr_reader :taxon

        delegate :type_taxt, :type_taxon, :protonym, to: :taxon

        def headline_type
          string = ''.html_safe
          string << type_name_and_taxt
          string << AddPeriodIfNecessary[protonym.biogeographic_region]
          string.html_safe
        end

        def type_name_and_taxt
          return ''.html_safe unless type_taxon

          string = taxon.decorate.type_taxon_rank
          string << Exporters::Antweb::Exporter.antcat_taxon_link_with_name(type_taxon)

          if type_taxt
            string << AntwebDetax[format_type_taxt]
          end

          AddPeriodIfNecessary[string]
        end

        def format_type_taxt
          taxon.decorate.format_type_taxt
        end
    end
  end
end
