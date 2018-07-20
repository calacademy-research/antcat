# rubocop:disable Rails/Output
module References
  module Cache
    class RegenerateAll
      include Service

      def call
        puts <<-MESSAGE.squish.yellow
          Regenerating all reference caches, this will take MANY minutes, depending
          on how many caches already are up-to-date.
        MESSAGE

        regenerate_all_references

        puts "Regenerating all reference caches done.".green
      end

      private

        def regenerate_all_references
          progress = Progress.create total: Reference.count

          Reference.find_each do |reference|
            progress.increment
            References::Cache::Regenerate[reference]
          end
        end
    end
  end
end
# rubocop:enable Rails/Output
