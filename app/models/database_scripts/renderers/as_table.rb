# frozen_string_literal: true

module DatabaseScripts
  module Renderers
    class AsTable
      FOUND_NO_DATABASE_ISSUES = "Found no database issues"

      # Cell, header and caption content is HTML. Values marked `html_safe` (built by `link_to`, formatters, etc.)
      # are used as-is. Plain strings may contain text entered by users, so they are sanitized: only formatting
      # tags and the attributes used by the app's own links are kept.
      ALLOWED_TAGS = Set.new(%w[a abbr b br code del div em i ins li ol p pre s small span strong sub sup u ul]).freeze
      ALLOWED_ATTRIBUTES = Set.new(%w[class href rel target title tooltip2]).freeze
      HOVER_PREVIEW_URL_REGEX = %r{\A/(catalog|protonyms|references)/\d+/hover_preview\.json\z}
      QUICK_FIX_PATH_REGEX = %r{\A/[a-z_/]*quick_and_dirty_fix(\?|\z)}

      CELL_SCRUBBER = Loofah::Scrubber.new do |node|
        next unless node.element?

        unless ALLOWED_TAGS.include?(node.name)
          node.remove
          next Loofah::Scrubber::STOP
        end

        node.attribute_nodes.each do |attribute|
          attribute.remove unless allowed_attribute?(node, attribute)
        end
      end

      def self.sanitize_html content
        return content if content.html_safe?

        fragment = Loofah.html5_fragment(content.to_s)
        fragment.scrub!(:prune)
        fragment.scrub!(CELL_SCRUBBER)
        fragment.to_s.html_safe
      end

      # Catalog tags (`{tax 1}`) are expanded into HTML after sanitizing, so attribute values must not contain them.
      def self.allowed_attribute? node, attribute
        value = attribute.value.to_s
        return false if value.include?("{") || value.include?("}")

        case attribute.name
        when 'data-controller' then value == 'hover-preview'
        when 'data-hover-preview-url-value' then value.match?(HOVER_PREVIEW_URL_REGEX)
        when 'data-method', 'data-remote' then node['href'].to_s.match?(QUICK_FIX_PATH_REGEX)
        else ALLOWED_ATTRIBUTES.include?(attribute.name)
        end
      end

      def initialize results
        @results = results
        @caption_content = nil
        @header_content = +""
        @body_content = +""
      end

      def render
        <<-HTML.html_safe
          <table class="table-striped" data-controller="tablesort">
            #{"<caption>#{caption_content}</caption>" if caption_content}
            #{"<caption>#{info_content}</caption>" if info_content}
            <thead>
              #{header_content}
            </thead>
            <tbody>#{Markdowns::ParseCatalogTags[body_content]}</tbody>
          </table>
        HTML
      end

      def caption string
        self.caption_content = sanitize_html(string)
      end

      def info string
        self.info_content = sanitize_html(string)
      end

      def header *items
        string = +"<tr>\n"
        items.each { |item| string << "<th>#{sanitize_html(item)}</th>\n" }
        string << "</tr>\n"

        header_content << string
      end

      # Defaults results to the script's `#results` unless specified.
      def rows rows_results = nil
        res = rows_results || results

        if res.blank?
          body_content << "<td>#{FOUND_NO_DATABASE_ISSUES}</td>" << "\n"
          return
        end

        res.each do |object|
          row object, *yield(object)
        end
      end

      private

        attr_accessor :results, :caption_content, :info_content, :header_content, :body_content

        def sanitize_html content
          self.class.sanitize_html(content)
        end

        def row _result, *fields
          return if fields.empty?

          string = +"<tr>"
          fields.each { |item| string << "<td>#{sanitize_html(item)}</td>" }
          body_content << string << "</tr>\n"
        end
    end
  end
end
