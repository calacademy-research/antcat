module Names
  class DuplicatesWithReferences
    include Service

    def initialize options = {}
      @options = options
    end

    def call
      results = {}
      dupes = duplicates

      Progress.new_init show_progress: options[:show_progress], total_count: dupes.size, show_errors: true
      dupes.each do |duplicate|
        Progress.puts duplicate.name
        Progress.tally_and_show_progress 1
        results[duplicate.name] ||= {}
        results[duplicate.name][duplicate.id] = duplicate.what_links_here
      end
      Progress.show_results

      results
    end

    private
      attr_reader :options

      def duplicates
        Name.where(name: name_strings).order(:name)
      end

      def name_strings
        Name.find_by_sql(<<-SQL).map(&:name)
          SELECT * FROM names GROUP BY name HAVING COUNT(*) > 1
        SQL
      end
  end
end
