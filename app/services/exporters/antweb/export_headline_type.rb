module Exporters
  module Antweb
    class ExportHeadlineType
      include Service
      include ApplicationHelper

      def initialize taxon
        @taxon = taxon
      end

      def call
        headline_type
      end

      private

        attr_reader :taxon

        delegate :type_taxt, :type_taxon, :biogeographic_region, to: :taxon

        def headline_type
          string = ''.html_safe
          string << type_name_and_taxt
          string << add_period_if_necessary(biogeographic_region)
          string.html_safe
        end

        def type_name_and_taxt
          return ''.html_safe unless type_taxon

          string = taxon.decorate.type_taxon_rank
          string << Exporters::Antweb::Exporter.antcat_taxon_link_with_name(type_taxon)

          if type_taxt
            string << AntwebDetax[format_type_taxt]
          end

          add_period_if_necessary string
        end

        def format_type_taxt
          taxon.decorate.format_type_taxt
        end
    end
  end
end
