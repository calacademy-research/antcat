module Markdowns
  class RenderWithoutWrappingP
    P_HTML_ELEMENT_REGEX = /\A<p>(.*)<\/p>\Z/m

    include Service

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
        Regexp.new(P_HTML_ELEMENT_REGEX).match(rendered)[1] rescue rendered
      end
  end
end
