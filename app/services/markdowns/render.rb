# frozen_string_literal: true

module Markdowns
  class Render
    include ActionView::Helpers::SanitizeHelper
    include Service

    def initialize content
      @content = sanitize(content)
    end

    def call
      markdowner.render(content).html_safe
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
        def postprocess content
          Markdowns::ParseAllTags[content]
        end

        def table header, body
          <<-HTML
            <table data-controller="tablesort">
              <thead>#{header}</thead>
              <tbody>#{body}</tbody>
            </table>
          HTML
        end
      end
  end
end
