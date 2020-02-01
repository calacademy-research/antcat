# Run in terminal: rake antcat:reference_caches:regenerate
# To run in Rails console: References::Cache::RegenerateAll[]

module References
  module Cache
    class RegenerateAll
      include Service

      def call
        progress = Progress.create total: Reference.count

        Reference.find_each do |reference|
          progress.increment
          References::Cache::Regenerate[reference]
        end
      end
    end
  end
end
