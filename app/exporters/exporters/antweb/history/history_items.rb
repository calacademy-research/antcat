# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class HistoryItems
        include ActionView::Helpers::TagHelper # For `#tag`.
        include ActionView::Context # For `#tag`.
        include Service

        attr_private_initialize :taxon

        def call
          return if history_items.blank?
          '<p><b>Taxonomic history</b></p>'.html_safe + history_content
        end

        private

          def history_items
            @_history_items ||= taxon.history_items_for_taxon
          end

          def history_content
            tag.div  do
              string = ''.html_safe

              history_items.each do |history_item|
                string << tag.div(AddPeriodIfNecessary[AntwebFormatter.detax(history_item.to_taxt)])
              end

              string
            end
          end
      end
    end
  end
end
