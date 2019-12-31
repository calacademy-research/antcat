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
        return if history_items.blank? && virtual_history_items.blank?
        '<p><b>Taxonomic history</b></p>'.html_safe + history_content
      end

      private

        attr_reader :taxon

        delegate :history_items, :virtual_history_items, to: :taxon

        def history_content
          content_tag :div do
            string = ''.html_safe

            history_items.each do |history_item|
              string << content_tag(:div, add_period_if_necessary(AntwebDetax[history_item.taxt]))
            end

            virtual_history_items.each do |history_item|
              string << content_tag(:div, history_item.render(formatter: AntwebFormatter))
            end

            string
          end
        end
    end
  end
end
