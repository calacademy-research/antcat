module Exporters
  module Antweb
    class ExportHistoryItems
      include ActionView::Helpers::TagHelper # For `#content_tag`.
      include ActionView::Context # For `#content_tag`.
      include ApplicationHelper
      include Service

      def initialize taxon
        @taxon = taxon
      end

      def call
        return if taxon.history_items.blank?

        history_content = content_tag :div do
          taxon.history_items.reduce(''.html_safe) do |content, item|
            content << history_item(item)
          end
        end

        '<p><b>Taxonomic history</b></p>'.html_safe + history_content
      end

      private

        attr_reader :taxon

        def history_item item
          content_tag :div do
            add_period_if_necessary AntwebDetax[item.taxt]
          end
        end
    end
  end
end
