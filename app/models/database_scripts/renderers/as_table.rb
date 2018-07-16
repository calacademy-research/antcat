module DatabaseScripts::Renderers::AsTable
  def as_table &block
    renderer = Renderer.new cached_results
    yield renderer
    renderer.render
  end

  class Renderer
    def initialize cached_results
      @cached_results = cached_results
      @header_content = ""
      @body_content = ""
    end

    def render
      <<-HTML.html_safe
        <table class="tablesorter hover margin-top">
          <thead>#{header_content}</thead>
          <tbody>#{Markdowns::ParseAntcatHooks[body_content]}</tbody>
        </table>
      HTML
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
        body_content << "<td>Found no database issues</td>" << "\n"
        return
      end

      method_name = if find_each then :find_each else :each end

      results.send(method_name) do |object|
        row object, *block.call(object)
      end
    end

    private

      attr :header_content, :body_content

      def row result, *fields
        string = "<tr>"
        fields.each { |item| string << "<td>#{item}</td>" }
        body_content << string << "</tr>\n"
      end
  end
end
