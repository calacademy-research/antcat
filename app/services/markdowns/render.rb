# frozen_string_literal: true

module Markdowns
  class Render
    include ActionView::Helpers::SanitizeHelper
    include Service

    # Attributes kept in content from any signed-in user (comments): no `class`, so a comment cannot be
    # styled like the site's own notices and warnings.
    USER_CONTENT_ATTRIBUTES = (ActionView::Helpers::SanitizeHelper.sanitizer_vendor.safe_list_sanitizer.allowed_attributes.to_a - %w[class]).freeze

    def initialize content, user_content: false
      sanitize_options = user_content ? { attributes: USER_CONTENT_ATTRIBUTES } : {}
      @content = sanitize(content, **sanitize_options).to_s.to_str
    end

    # Tags are expanded in `AntCatMarkdown#postprocess`; attribute values from the content are kept out of that.
    def call
      Markdowns::ExpandOutsideAttributes.call(content) { |masked| markdowner.render(masked) }.html_safe
    end

    private

      attr_reader :content

      def markdowner
        extensions = {
          autolink: true,
          superscript: true,
          disable_indented_code_blocks: true,
          tables: true,
          underline: false,
          no_intra_emphasis: true,
          strikethrough: true,
          fenced_code_blocks: true
        }

        Redcarpet::Markdown.new(renderer, extensions)
      end

      def renderer
        options = {
          hard_wrap: true,
          space_after_headers: true,
          underline: false
        }

        AntCatMarkdown.new(options)
      end

      class AntCatMarkdown < Redcarpet::Render::HTML
        SAFE_SCHEMES = %w[http https mailto].freeze
        # Matches a URI scheme ("javascript:", "data:", ...) at the start of a URL.
        SCHEME_REGEX = /\A([a-z][a-z0-9+.-]*):/i
        # Characters that start an AntCat tag; encoded in attributes built here so `postprocess` leaves them alone.
        TAG_TRIGGER_REGEX = /[{}]|@(?=user\d)|%(?=github\d|wiki\d|dbscript:)/

        def self.safe_url? url
          return false if url.blank?

          # Decode entities and drop whitespace/control characters that browsers ignore,
          # so that e.g. "java&#09;script:" or " javascript:" are caught too.
          normalized = CGI.unescapeHTML(url.to_s).gsub(/[[:space:][:cntrl:]]/, '')
          return true unless (match = normalized.match(SCHEME_REGEX))

          SAFE_SCHEMES.include?(match[1].downcase)
        end

        def postprocess content
          Markdowns::ParseAllTags[content]
        end

        # Only http(s), mailto, relative URLs and anchors are rendered as links;
        # anything else (e.g. `javascript:`) is rendered as plain text.
        def link link, title, content
          return content unless self.class.safe_url?(link)

          %(<a href="#{attribute_value(link)}"#{title_attribute(title)}>#{content}</a>)
        end

        def image link, title, alt_text
          return escape_attribute(alt_text) unless self.class.safe_url?(link)

          %(<img src="#{attribute_value(link)}" alt="#{attribute_value(alt_text)}"#{title_attribute(title)}>)
        end

        def autolink link, link_type
          url = link_type == :email ? "mailto:#{link}" : link
          return escape_attribute(link) unless self.class.safe_url?(url)

          %(<a href="#{attribute_value(url)}">#{escape_attribute(link)}</a>)
        end

        def table header, body
          <<-HTML
            <table data-controller="tablesort">
              <thead>#{header}</thead>
              <tbody>#{body}</tbody>
            </table>
          HTML
        end

        private

          # Content has already been sanitized (which turns "&" into "&amp;"), so unescape
          # first to avoid double-escaping.
          def escape_attribute value
            ERB::Util.html_escape(CGI.unescapeHTML(value.to_s)).to_str
          end

          def attribute_value value
            escape_attribute(value).gsub(TAG_TRIGGER_REGEX) { |char| "&##{char.ord};" }
          end

          def title_attribute title
            return '' if title.blank?
            %( title="#{attribute_value(title)}")
          end
      end
  end
end
