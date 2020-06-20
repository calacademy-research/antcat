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
              [
                protonym_name,
                authorship(protonym.authorship),
                (AntwebFormatter.detax(protonym.notes_taxt) if protonym.notes_taxt),
                ('[sic]' if protonym.sic?),
                protonym.decorate.format_locality
              ].compact.join(" ").html_safe
            end

            def protonym_name
              tag.b protonym.decorate.name_with_fossil
            end

            def authorship authorship
              string = AntwebFormatter.link_to_reference(authorship.reference)
              string << ": "
              string << protonym.decorate.format_pages_and_forms
              string
            end
        end
      end
    end
  end
end
