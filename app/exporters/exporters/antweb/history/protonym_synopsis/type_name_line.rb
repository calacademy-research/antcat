# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class ProtonymSynopsis
        class TypeNameLine
          include Service

          attr_private_initialize :protonym

          def call
            type_name_line
          end

          private

            def type_name_line
              string = ''.html_safe
              string << type_name_and_taxt
              string << AddPeriodIfNecessary[protonym.biogeographic_region]
              string.html_safe
            end

            def type_name_and_taxt
              return ''.html_safe unless (type_name = protonym.type_name)
              type_name_decorated = type_name.decorate

              string = type_name_decorated.format_rank
              string << AntwebFormatter.link_to_taxon(type_name.taxon)

              if (formatted_fixation_method = type_name_decorated.format_fixation_method)
                string << AntwebFormatter.detax(formatted_fixation_method)
              end

              AddPeriodIfNecessary[string]
            end
        end
      end
    end
  end
end
