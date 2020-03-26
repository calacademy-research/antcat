# frozen_string_literal: true

module Exporters
  module Antweb
    class ExportChildList
      include ActionView::Context # For `#content_tag`.
      include ActionView::Helpers::TagHelper # For `#content_tag`.
      include Service

      def initialize taxon
        @taxon = taxon
      end

      def call
        content = ''.html_safe

        Taxa::ChildList[taxon].each do |child_list|
          content << child_list(child_list[:label], child_list[:children])
        end

        content
      end

      private

        attr_reader :taxon

        def child_list label, children
          return ''.html_safe if children.blank?

          content_tag :div do
            content = ''.html_safe
            content << content_tag(:span, label, class: 'caption')
            content << ': '
            content << child_list_items(children)
          end
        end

        def child_list_items children
          children.map { |child| Exporters::Antweb::Exporter.antcat_taxon_link_with_name child }.join(', ').html_safe
        end
    end
  end
end
