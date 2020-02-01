# Run in terminal: rake antcat:reference_caches:regenerate
# To run in Rails console: References::Cache::RegenerateAll[]

module References
  module Cache
    class RegenerateAll
      include Service

      def call
        progress = progress_bar Reference.count

        Reference.find_each do |reference|
          progress.increment
          References::Cache::Regenerate[reference]
        end
      end

      private

        def progress_bar total
          ProgressBar.create total: total, format: "%a %e %P% Processed: %c from %C", throttle_rate: 0.5
        end
    end
  end
end
