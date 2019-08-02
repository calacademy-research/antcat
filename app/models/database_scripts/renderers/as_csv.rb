require 'csv'

module DatabaseScripts
  module Renderers
    module AsCSV
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

        def rows results = nil, &block
          results ||= @cached_results

          results.each do |object|
            @rows.push block.call(object)
          end
        end
      end
    end
  end
end
