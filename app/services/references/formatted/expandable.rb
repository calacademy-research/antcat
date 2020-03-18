# Formats the reference with HTML, CSS, etc. Click to show expanded.

module References
  module Formatted
    class Expandable
      include ActionView::Context # For `#content_tag`.
      include ActionView::Helpers::TagHelper # For `#content_tag`.
      include ActionView::Helpers::SanitizeHelper
      include Service

      def initialize reference
        @reference = reference
      end

      def call
        # TODO: `tabindex: 2` is required or tooltips won't stay open even with `data-click-open="true"`.
        content_tag :span, sanitize(reference.keey),
          data: { tooltip: true, allow_html: "true", tooltip_class: "foundation-tooltip" },
          tabindex: "2", title: inner_content.html_safe
      end

      private

        attr_reader :reference

        def inner_content
          content = []
          content << References::Formatted::Expanded[reference]
          content << reference.decorate.format_document_links
          content.reject(&:blank?).join(' ')
        end
    end
  end
end
