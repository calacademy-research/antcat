# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class ReferenceSections
        include ActionView::Context # For `#tag`.
        include ActionView::Helpers::TagHelper # For `#tag`.
        include Service

        attr_private_initialize :taxon

        def call
          return if taxon.reference_sections.blank?

          tag.div do
            taxon.reference_sections.reduce(''.html_safe) do |content, section|
              content << reference_section(section)
            end
          end
        end

        private

          def reference_section section
            tag.div do
              [:title_taxt, :subtitle_taxt, :references_taxt].each_with_object(''.html_safe) do |field, content|
                if section[field]
                  content << tag.div(AntwebFormatter.detax(section[field]))
                end
              end
            end
          end
      end
    end
  end
end
