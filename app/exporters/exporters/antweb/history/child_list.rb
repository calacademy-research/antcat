# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class ChildList
        include ActionView::Context # For `#content_tag`.
        include ActionView::Helpers::TagHelper # For `#content_tag`.
        include Service

        attr_private_initialize :taxon

        def call
          content = ''.html_safe

          ::Taxa::ChildList[taxon].each do |child_list|
            content << child_list(child_list[:label], child_list[:children])
          end

          content
        end

        private

          def child_list label, children
            return ''.html_safe if children.blank?

            content_tag :div do
              content = ''.html_safe
              content << content_tag(:span, label, class: 'caption')
              content << ': '
              content << children_links(children)
            end
          end

          def children_links children
            children.map { |child| AntwebFormatter.link_to_taxon(child) }.join(', ').html_safe
          end
      end
    end
  end
end
