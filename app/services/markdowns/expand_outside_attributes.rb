# frozen_string_literal: true

# AntCat expands its own tags (`@user1`, `%github1`, `{tax 1}`, specimen identifiers, ...) into HTML after
# the content has been sanitized. An expansion must never run inside an attribute value, since the inserted
# markup would end the attribute. This runs a block of expansions on the HTML with every attribute value
# replaced by a placeholder, then puts the values back (escaped), so attribute values are never touched.
#
# Text nodes are not expanded one by one because some tags may span elements (`{missing <i>Lasius</i>}`).
#
# Usage: `Markdowns::ExpandOutsideAttributes.call(sanitized_html) { |html| Markdowns::ParseCatalogTags[html] }`
module Markdowns
  class ExpandOutsideAttributes
    OPEN = "\u{E000}"
    CLOSE = "\u{E001}"
    MARKERS_REGEX = /[#{OPEN}#{CLOSE}]/o
    PLACEHOLDER_REGEX = /#{OPEN}(\d+)#{CLOSE}/o
    ATTRIBUTE_ESCAPES = { '&' => '&amp;', '"' => '&quot;', '<' => '&lt;', '>' => '&gt;', " " => '&nbsp;', '{' => '&#123;', '}' => '&#125;' }.freeze
    ATTRIBUTE_ESCAPES_REGEX = /[&"<> {}]/

    def self.call html
      expander = new(html)
      expander.unmask(yield(expander.masked))
    end

    attr_reader :masked

    def initialize html
      @values = []
      @masked = mask(String.new(html.to_s).gsub(MARKERS_REGEX, ''))
    end

    # Braces are escaped too, so that running catalog tag expansion again over the output (as database
    # script tables do) cannot expand a tag inside an attribute value either.
    def unmask html
      return html if values.empty?

      String.new(html.to_s).gsub(PLACEHOLDER_REGEX) do
        values.fetch(Regexp.last_match(1).to_i, '').gsub(ATTRIBUTE_ESCAPES_REGEX, ATTRIBUTE_ESCAPES)
      end
    end

    private

      attr_reader :values

      def mask html
        return html unless html.include?('<') && html.include?('=')

        fragment = parse_fragment(html)
        fragment.traverse do |node|
          next unless node.element?

          node.attribute_nodes.each do |attribute|
            placeholder = "#{OPEN}#{values.size}#{CLOSE}"
            values << attribute.value.to_s
            attribute.value = placeholder
          end
        end
        return html if values.empty?

        fragment.to_s
      end

      # Use the same parser as the sanitizer, so that re-serializing sanitized HTML does not change it.
      def parse_fragment html
        if ActionView::Helpers::SanitizeHelper.sanitizer_vendor.name.include?('HTML5')
          Loofah.html5_fragment(html)
        else
          Loofah.html4_fragment(html)
        end
      end
  end
end
