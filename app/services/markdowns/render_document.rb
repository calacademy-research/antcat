# frozen_string_literal: true

# Renders a whole document written in Markdown (a notes page), with everything an .md file has: quotations
# ("> ..."), tables, headings, HTML such as <i>.
#
# `Markdowns::Render` sanitizes the source and then lets Markdown read it, which turns the ">" of a quotation
# into "&gt;". Here Markdown reads the source as written and the HTML it produces is sanitized, so whatever the
# source holds, only the listed tags and attributes reach the page. AntCat's tags are expanded last, outside
# attribute values, as in `Markdowns::Render`.
module Markdowns
  class RenderDocument
    include ActionView::Helpers::SanitizeHelper
    include Service

    TABLE_TAGS = %w[table thead tbody tr th td].freeze
    ALLOWED_TAGS = (ActionView::Helpers::SanitizeHelper.sanitizer_vendor.safe_list_sanitizer.allowed_tags.to_a + TABLE_TAGS).freeze
    # Without `class`, so a document cannot be styled like the site's own notices and warnings.
    ALLOWED_ATTRIBUTES = Markdowns::Render::USER_CONTENT_ATTRIBUTES

    EXTENSIONS = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true,
      tables: true,
      underline: false,
      no_intra_emphasis: true,
      strikethrough: true,
      fenced_code_blocks: true
    }.freeze
    RENDERER_OPTIONS = { hard_wrap: true, space_after_headers: true, underline: false }.freeze

    def initialize content
      @content = content.to_s
    end

    def call
      html = sanitize(rendered_markdown, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES).to_s.to_str
      Markdowns::ExpandOutsideAttributes.call(html) { |masked| Markdowns::ParseAllTags[masked] }.html_safe
    end

    private

      attr_reader :content

      def rendered_markdown
        Redcarpet::Markdown.new(DocumentMarkdown.new(RENDERER_OPTIONS), EXTENSIONS).render(content)
      end

      # Links and images as in `Markdowns::Render` (safe URL schemes only).
      class DocumentMarkdown < Markdowns::Render::AntCatMarkdown
        # Tags are expanded after sanitizing (see `RenderDocument#call`), not here.
        def postprocess content
          content
        end

        # The source was not sanitized before Markdown read it, so the code is escaped as it is.
        def block_code code, _language
          %(<pre><code>#{ERB::Util.html_escape(code)}</code></pre>\n)
        end

        def table header, body
          "<table><thead>#{header}</thead><tbody>#{body}</tbody></table>\n"
        end
      end
  end
end
