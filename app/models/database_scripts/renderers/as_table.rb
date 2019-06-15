module DatabaseScripts
  module Renderers
    module AsTable
      FOUND_NO_DATABASE_ISSUES = "Found no database issues"

      def as_table
        renderer = Renderer.new cached_results
        yield renderer
        renderer.render
      end

      class Renderer
        def initialize cached_results
          @cached_results = cached_results
          @caption_content = nil
          @header_content = ""
          @body_content = ""
        end

        def render
          <<-HTML.html_safe
            <table class="tablesorter hover margin-top">
              #{"<caption>#{caption_content}</caption>" if caption_content}
              <thead>#{header_content}</thead>
              <tbody>#{Markdowns::ParseAntcatHooks[body_content, sanitize_content: false]}</tbody>
            </table>
          HTML
        end

        def caption string
          self.caption_content = string
        end

        def header *items
          string = "<tr>\n"
          items.each { |item| string << "<th>#{item.to_s.humanize}</th>\n" }
          string << "</tr>\n"

          header_content << string
        end

        # Gets the results from `#results` unless specified.
        def rows results = nil, find_each: false, &block
          results ||= @cached_results

          if results.blank?
            body_content << "<td>#{FOUND_NO_DATABASE_ISSUES}</td>" << "\n"
            return
          end

          method_name = if find_each then :find_each else :each end

          results.send(method_name) do |object|
            row object, *block.call(object)
          end
        end

        private

          attr_accessor :caption_content, :header_content, :body_content

          def row _result, *fields
            string = "<tr>"
            fields.each { |item| string << "<td>#{item}</td>" }
            body_content << string << "</tr>\n"
          end
      end
    end
  end
end
