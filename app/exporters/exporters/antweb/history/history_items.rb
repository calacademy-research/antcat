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
          return if history_items.blank? && virtual_history_items.blank?
          '<p><b>Taxonomic history</b></p>'.html_safe + history_content
        end

        private

          delegate :history_items, :virtual_history_items, to: :taxon, private: true

          def history_content
            tag.div  do
              string = ''.html_safe

              history_items.each do |history_item|
                string << tag.div(AddPeriodIfNecessary[AntwebFormatter.detax(history_item.to_taxt)])
              end

              virtual_history_items.each do |history_item|
                string << tag.div(history_item.render(formatter: AntwebFormatter))
              end

              string
            end
          end
      end
    end
  end
end
