# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class Headline
        class HeadlineType
          include Service

          attr_private_initialize :taxon

          def call
            headline_type
          end

          private

            delegate :type_taxt, :type_taxon, :protonym, to: :taxon, private: true

            def headline_type
              string = ''.html_safe
              string << type_name_and_taxt
              string << AddPeriodIfNecessary[protonym.biogeographic_region]
              string.html_safe
            end

            def type_name_and_taxt
              return ''.html_safe unless type_taxon

              string = taxon.decorate.type_taxon_rank
              string << AntwebFormatter.link_to_taxon(type_taxon)

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
  end
end
