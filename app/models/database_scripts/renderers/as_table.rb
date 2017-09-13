module DatabaseScripts::Renderers::AsTable
  def as_table &block
    renderer = Renderer.new cached_results
    yield renderer
    renderer.render
  end

  class Renderer
    def initialize cached_results
      @cached_results = cached_results
      @rendered = ""
    end

    def render
      Markdowns::Render.new(@rendered).call
    end

    def header *items
      # Say `items` are the array [:taxon, :status], then this part looks
      # like this: "| Taxon | Status |".
      string = "|"
      items.each { |item| string << " #{item.to_s.humanize} |" }
      string << "\n"

      # Part of the markdown table syntax. Looks like: "| --- | --- |".
      string << "|" << (" --- |" * items.size) << "\n"

      @rendered << string
    end

    # Gets the results from `#results` unless specified.
    def rows results = nil, find_each: false, &block
      results ||= @cached_results

      if results.blank?
        @rendered << "| Found no database issues |" << "\n"
        return
      end

      method_name = if find_each then :find_each else :each end

      results.send(method_name) do |object|
        row object, *block.call(object)
      end
    end

    private
      def row result, *fields
        string = "|"
        fields.each { |item| string << " #{item} |" }
        @rendered << string << "\n"
      end
  end
end
