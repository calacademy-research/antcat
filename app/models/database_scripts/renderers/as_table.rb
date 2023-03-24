# frozen_string_literal: true

module DatabaseScripts
  module Renderers
    class AsTable
      FOUND_NO_DATABASE_ISSUES = "Found no database issues"

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
        self.caption_content = string
      end

      def info string
        self.info_content = string
      end

      def header *items
        string = +"<tr>\n"
        items.each { |item| string << "<th>#{item}</th>\n" }
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

        def row _result, *fields
          return if fields.empty?

          string = +"<tr>"
          fields.each { |item| string << "<td>#{item}</td>" }
          body_content << string << "</tr>\n"
        end
    end
  end
end
