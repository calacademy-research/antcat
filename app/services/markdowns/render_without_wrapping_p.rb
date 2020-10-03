# frozen_string_literal: true

module Markdowns
  class RenderWithoutWrappingP
    include Service

    P_HTML_ELEMENT_REGEX = %r{\A<p>(.*)</p>\Z}m

    attr_private_initialize :content

    def call
      return unless content
      rendered = Markdowns::Render[content.dup]
      strip_wrapping_p(rendered).html_safe
    end

    private

      def strip_wrapping_p rendered
        return rendered unless (match = rendered.match(P_HTML_ELEMENT_REGEX))
        match[1]
      end
  end
end
