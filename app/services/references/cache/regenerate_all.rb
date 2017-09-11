module References
  module Cache
    class RegenerateAll
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
          Progress.new_init show_progress: true, total_count: Reference.count
          Reference.find_each do |reference|
            Progress.tally_and_show_progress 100
            References::Cache::Regenerate.new(reference).call
          end
          Progress.show_results
        end
    end
  end
end
