# frozen_string_literal: true

# Formats the reference with HTML, CSS, etc. Click to show expanded.

module References
  module Formatted
    class Expandable
      include ActionView::Context # For `#tag`.
      include ActionView::Helpers::TagHelper # For `#tag`.
      include ActionView::Helpers::SanitizeHelper
      include Service

      attr_private_initialize :reference

      def call
        # TODO: `tabindex: "0"` is required or tooltips won't stay open even with `data-click-open="true"`.
        tag.span sanitize(reference.keey),
          data: { tooltip: true, allow_html: "true", tooltip_class: "foundation-tooltip" },
          tabindex: "0", title: inner_content.html_safe
      end

      private

        def inner_content
          content = []
          content << References::Formatted::Expanded[reference]
          content << reference.decorate.format_document_links
          content.compact.join(' ')
        end
    end
  end
end
