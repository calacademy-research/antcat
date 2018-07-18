require 'csv'

module DatabaseScripts::Renderers::AsCSV
  def as_csv
    renderer = Renderer.new cached_results
    yield renderer
    renderer.render
  end

  class Renderer
    def initialize cached_results
      @cached_results = cached_results
      @rows = []
    end

    def render
      CSV.generate do |csv|
        csv << @headers

        @rows.each do |row|
          csv << row
        end
      end
    end

    def header *items
      @headers = items
    end

    def rows results = nil, find_each: false, &block
      results ||= @cached_results

      method_name = if find_each then :find_each else :each end

      results.send(method_name) do |object|
        @rows.push block.call(object)
      end
    end
  end
end
