module Markdowns
  class RenderWithoutWrappingP
    include Service

    P_HTML_ELEMENT_REGEX = /\A<p>(.*)<\/p>\Z/m

    def initialize content
      @content = content
    end

    def call
      return unless content
      rendered = Markdowns::Render[content.dup]
      strip_wrapping_p(rendered).html_safe
    end

    private

      attr_reader :content

      def strip_wrapping_p rendered
        Regexp.new(P_HTML_ELEMENT_REGEX).match(rendered)[1]
      rescue StandardError # TODO: Do not rescue `StandardError`.
        rendered
      end
  end
end
