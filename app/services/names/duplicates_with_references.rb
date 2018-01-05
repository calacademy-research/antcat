module Names
  class DuplicatesWithReferences
    include Service

    def initialize options = {}
      @options = options
    end

    def call
      results = {}
      progress = Progress.create total: duplicates.count

      duplicates.each do |duplicate|
        progress.increment
        results[duplicate.name] ||= {}
        results[duplicate.name][duplicate.id] = duplicate.what_links_here
      end

      results
    end

    private
      attr_reader :options

      def duplicates
        Name.where(name: name_strings).order(:name)
      end

      def name_strings
        Name.find_by_sql(<<-SQL).map(&:name)
          SELECT name FROM names GROUP BY name HAVING COUNT(*) > 1
        SQL
      end
  end
end
