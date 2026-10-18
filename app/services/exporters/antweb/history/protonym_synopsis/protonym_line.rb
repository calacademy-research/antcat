# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class ProtonymSynopsis
        class ProtonymLine
          include ActionView::Context # For `#tag`.`
          include ActionView::Helpers::TagHelper # For `#tag`.`
          include Service

          attr_private_initialize :protonym

          def call
            AddPeriodIfNecessary[protonym_line]
          end

          private

            def protonym_line
              # `safe_join` escapes the parts that are plain strings (the locality is user-entered text).
              safe_join(
                [
                  protonym_name,
                  format_authorship,
                  (AntwebFormatter.detax(protonym.notes_taxt) if protonym.notes_taxt),
                  ('[sic]' if protonym.sic?),
                  protonym.decorate.format_locality
                ].compact,
                " "
              )
            end

            def protonym_name
              tag.b protonym.name_with_fossil
            end

            def format_authorship
              string = AntwebFormatter.link_to_reference(protonym.authorship_reference)
              string << ": "
              string << protonym.decorate.format_pages_and_forms
              string
            end
        end
      end
    end
  end
end
